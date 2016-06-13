require 'json'
require 'net/http'
require 'uri'

require_relative 'formatters/reporter'

module Hiptest

  class ClientError < StandardError
  end

  class Client
    attr_reader :cli_options

    def initialize(cli_options, reporter = nil)
      @cli_options = cli_options
      @reporter = reporter || NullReporter.new
    end

    def url
      if cli_options.push?
        "#{cli_options.site}/import_test_results/#{cli_options.token}/#{cli_options.push_format}"
      elsif test_run_id
        "#{base_publication_path}/test_run/#{test_run_id}"
      else
        "#{base_publication_path}/#{cli_options.leafless_export ? 'leafless_tests' : 'project'}"
      end
    end

    def fetch_project_export
      response = send_get_request(url)
      response.body
    end

    def available_test_runs
      @available_test_runs ||= begin
        response = send_get_request("#{base_publication_path}/test_runs")
        json_response = JSON.parse(response.body)
        json_response["test_runs"]
      end
    end

    def push_results
      # Code from: https://github.com/nicksieger/multipart-post
      uploaded = {}
      Dir.glob(cli_options.push.gsub('\\', '/')).each_with_index do |filename, index|
        uploaded["file-#{filename.normalize}"] = UploadIO.new(File.new(filename), "text", filename)
      end

      uri = URI.parse(url)
      send_request(Net::HTTP::Post::Multipart.new(uri, uploaded))
    end

    private

    def test_run_id
      if cli_options.test_run_id && !cli_options.test_run_id.empty?
        cli_options.test_run_id
      elsif cli_options.test_run_name && !cli_options.test_run_name.empty?
        matching_test_run = available_test_runs.find { |test_run| test_run["name"] == cli_options.test_run_name }
        if matching_test_run.nil?
          raise ClientError, no_matching_test_runs_error_message
        end
        matching_test_run["id"]
      end
    end

    def no_matching_test_runs_error_message
      if available_test_runs.empty?
        "No matching test run found: this project does not have any test runs."
      else
        "No matching test run found. Available test runs for this project are:\n" +
        format_available_test_runs
      end
    end

    def format_available_test_runs
      lines = []
      lines << ["ID", "Name"]
      lines << ["--", "----"]
      lines += available_test_runs.map { |tr| [tr["id"].to_s, tr["name"]] }
      first_column_width = lines.map { |line| line[0].length }.max
      lines.map! { |line| "  #{line[0].ljust(first_column_width)}  #{line[1]}" }
      lines.join("\n")
    end

    def base_publication_path
      "#{cli_options.site}/publication/#{cli_options.token}"
    end

    def send_get_request(url)
      uri = URI.parse(url)
      response = send_request(Net::HTTP::Get.new(uri))
      if response.code_type == Net::HTTPNotFound
        raise ClientError, "No project found with this secret token."
      end
      response
    end

    def send_request(request)
      request["User-Agent"] = "Ruby/hiptest-publisher"
      use_ssl = request.uri.scheme == "https"
      Net::HTTP.start(request.uri.hostname, request.uri.port, use_ssl: use_ssl, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
        @reporter.show_verbose_message("Request sent to: #{request.uri}")
        http.request(request)
      end
    end
  end
end
