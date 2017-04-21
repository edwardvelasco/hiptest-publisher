require_relative 'spec_helper'
require_relative "render_shared"

describe 'Render as <My language>' do
  include_context "shared render"

  before(:each) do
    # In Hiptest: null
    @null_rendered = 'null'

    # In Hiptest: 'What is your quest ?'
    @what_is_your_quest_rendered = '"What is your quest ?"'

    # In Hiptest: 3.14
    @pi_rendered = '3.14'

    # In Hiptest: false
    @false_rendered = 'false'

    # In Hiptest: "${foo}fighters"
    @foo_template_rendered = '"${foo}fighters"'

    # In Hiptest: "Fighters said \"Foo !\""
    @double_quotes_template_rendered = '"Fighters said \"Foo !\""'

    # In Hiptest: ""
    @empty_template_rendered = '""'

    # In Hiptest: foo (as in 'foo := 1')
    @foo_variable_rendered = 'foo'

    # In Hiptest: foo.fighters
    @foo_dot_fighters_rendered = 'foo.fighters'

    # In Hiptest: foo['fighters']
    @foo_brackets_fighters_rendered = 'foo["fighters"]'

    # In Hiptest: -foo
    @minus_foo_rendered = '-foo'

    # In Hiptest: foo - 'fighters'
    @foo_minus_fighters_rendered = 'foo - "fighters"'

    # In Hiptest: (foo)
    @parenthesis_foo_rendered = '(foo)'

    # In Hiptest: [foo, 'fighters']
    @foo_list_rendered = '[foo, "fighters"]'

    # In Hiptest: foo: 'fighters'
    @foo_fighters_prop_rendered = 'foo: "fighters"'

    # In Hiptest: {foo: 'fighters', Alt: J}
    @foo_dict_rendered = '[foo: "fighters", Alt: J]'

    # In Hiptest: foo := 'fighters'
    @assign_fighters_to_foo_rendered = 'foo = "fighters"'

    # In Hiptest: call 'foo'
    @call_foo_rendered = "foo"
    # In Hiptest: call 'foo bar'
    @call_foo_bar_rendered = "fooBar"

    # In Hiptest: call 'foo'('fighters')
    @call_foo_with_fighters_rendered = 'foo("fighters")'
    # In Hiptest: call 'foo bar'('fighters')
    @call_foo_bar_with_fighters_rendered = 'fooBar("fighters")'

    # In Hiptest: step {action: "${foo}fighters"}
    @action_foo_fighters_rendered = '# TODO: Implement action: "${foo}fighters"'

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    #end
    @if_then_rendered = [
        "if (true) {",
        '  foo = "fighters";',
        "}\n"
      ].join("\n")

    # In Hiptest:
    # if (true)
    #   foo := 'fighters'
    # else
    #   fighters := 'foo'
    #end
    @if_then_else_rendered = [
        "if (true) {",
        '  foo = "fighters"',
        "} else {",
        '  fighters = "foo"',
        "}\n"
      ].join("\n")

    # In Hiptest:
    # while (foo)
    #   fighters := 'foo'
    #   foo('fighters')
    # end
    @while_loop_rendered = [
        "while (foo)",
        '  fighters = "foo"',
        '  foo('fighters')',
        "end\n"
      ].join("\n")

    # In Hiptest: @myTag
    @simple_tag_rendered = 'myTag'

    # In Hiptest: @myTag:somevalue
    @valued_tag_rendered = 'myTag:somevalue'

    # In Hiptest: plic (as in: definition 'foo'(plic))
    @plic_param_rendered = 'plic'

    # In Hiptest: plic = 'ploc' (as in: definition 'foo'(plic = 'ploc'))
    @plic_param_default_ploc_rendered = 'plic = "ploc"'

    # In Hiptest:
    # actionword 'my action word' do
    # end
    @empty_action_word_rendered = "def myActionWord(){\n}"

    # In Hiptest:
    # @myTag @myTag:somevalue
    # actionword 'my action word' do
    # end
    @tagged_action_word_rendered = [
      "def myActionWord() {",
      "  // Tags: myTag myTag:somevalue",
      "}"].join("\n")

    @described_action_word_rendered = ''

    # In Hiptest:
    # actionword 'my action word' (plic, flip = 'flap') do
    # end
    @parameterized_action_word_rendered = [
      "def myActionWord(plic, flip = 'flap') {",
      "}"].join("\n")

    # In Hiptest:
    # @myTag
    # actionword 'compare to pi' (x) do
    #   foo := 3.14
    #   if (foo > x)
    #     step {result: "x is greater than Pi"}
    #   else
    #     step {result: "x is lower than Pi
    #       on two lines"}
    #   end
    # end
    @full_actionword_rendered = [
      "def compareToPi(x) {",
      "  // Tags: myTag",
      "  foo = 3.14",
      "  if (foo > x) {",
      "    // TODO: Implement result: x is greater than Pi",
      "  } else {",
      "    // TODO: Implement result: x is lower than Pi",
      "    // on two lines",
      "  }",
      "}"].join("\n")

    # In Hiptest:
    # actionword 'my action word' do
    #   step {action: "basic action"}
    # end
    @step_action_word_rendered = [
      "def myActionWord() {",
      "  // TODO: Implement action: basic action",
      "  throw new UnsupportedOperationException",
      "}"].join("\n")

    # In Hiptest, correspond to two action words:
    # actionword 'first action word' do
    # end
    # actionword 'second action word' do
    #   call 'first action word'
    # end
    @actionwords_rendered = [
      "class Actionwords {",
      "  def firstActionWord() {",
      "  }",
      "",
      "  def secondActionWord() {",
      "    first_action_word();",
      "  }",
      "}"].join("\n")

    # In Hiptest, correspond to these action words with parameters:
    # actionword 'aw with int param'(x) do end
    # actionword 'aw with float param'(x) do end
    # actionword 'aw with boolean param'(x) do end
    # actionword 'aw with null param'(x) do end
    # actionword 'aw with string param'(x) do end
    #
    # but called by this scenario
    # scenario 'many calls scenarios' do
    #   call 'aw with int param'(x = 3)
    #   call 'aw with float param'(x = 4.2)
    #   call 'aw with boolean param'(x = true)
    #   call 'aw with null param'(x = null)
    #   call 'aw with string param'(x = 'toto')
    #   call 'aw with template param'(x = "toto")
    @actionwords_with_params_rendered = [
      "class Actionwords {",
      "  def awWithIntParam(x) {",
      "  }",
      "",
      "  def awWithFloatParam(x) {",
      "  }",
      "",
      "  def awWithBooleanParam(x) {",
      "  }",
      "",
      "  def awWithNullParam(x) {",
      "  }",
      "",
      "  def awWithStringParam(x) {",
      "  }",
      "",
      "  def awWithTemplateParam(x) {",
      "  }",
      "}"
    ].join("\n")

    # XXXXXXXXXXXXX-------------- STOPPED HERE FOR NOW

    # In Hiptest:
    # @myTag
    # scenario 'compare to pi' (x) do
    #   foo := 3.14
    #   if (foo > x)
    #     step {result: "x is greater than Pi"}
    #   else
    #     step {result: "x is lower than Pi
    #       on two lines"}
    #   end
    # end
    @full_scenario_rendered = [
      "it 'compare_to_pi' do",
      "  # This is a scenario which description ",
      "  # is on two lines",
      "  # Tags: myTag",
      "  foo = 3.14",
      "  if (foo > x)",
      "    # TODO: Implement result: x is greater than Pi",
      "  else",
      "    # TODO: Implement result: x is lower than Pi",
      "    # on two lines",
      "  end",
      "end"].join("\n")

    @full_scenario_with_uid_rendered = [
      "def test_compare_to_pi_uidabcd1234",
      "  # This is a scenario which description ",
      "  # is on two lines",
      "  # Tags: myTag",
      "  foo = 3.14",
      "  if (foo > x)",
      "    # TODO: Implement result: x is greater than Pi",
      "  else",
      "    # TODO: Implement result: x is lower than Pi",
      "    # on two lines",
      "  end",
      "  raise NotImplementedError",
      "end"].join("\n")

    # In hiptest
    # scenario 'reset password' do
    #   call given 'Page "url" is opened'(url='/login')
    #   call when 'I click on "link"'(link='Reset password')
    #   call then 'page "url" should be opened'(url='/reset-password')
    # end
    @bdd_scenario_rendered = [
    ].join("\n")

    # Same than previous scenario, except that is is rendered
    # so it can be used in a single file (using the --split-scenarios option)
    @full_scenario_rendered_for_single_file = [
      "it 'compare_to_pi' do",
      "  # This is a scenario which description ",
      "  # is on two lines",
      "  # Tags: myTag",
      "  foo = 3.14",
      "  if (foo > x)",
      "    # TODO: Implement result: x is greater than Pi",
      "  else",
      "    # TODO: Implement result: x is lower than Pi",
      "    # on two lines",
      "  end",
      "end"].join("\n")

    # Scenario definition is:
    # call 'fill login' (login = login)
    # call 'fill password' (password = password)
    # call 'press enter'
    # call 'assert "error" is displayed' (error = expected)

    # Scenario datatable is:
    # Dataset name             | login   | password | expected
    # -----------------------------------------------------------------------------
    # Wrong 'login'            | invalid | invalid  | 'Invalid username or password
    # Wrong "password"         | valid   | invalid  | 'Invalid username or password
    # Valid 'login'/"password" | valid   | valid    | nil

    @scenario_with_datatable_rendered = [
      "context \"check login\" do",
      "  def check_login(login, password, expected)",
      "    \# Ensure the login process",
      "    fill_login(login)",
      "    fill_password(password)",
      "    press_enter",
      "    assert_error_is_displayed(expected)",
      "  end",
      "",
      "  it \"Wrong login\" do",
      "    check_login('invalid', 'invalid', 'Invalid username or password')",
      "  end",
      "",
      "  it \"Wrong \\\"password\\\"\" do",
      "    check_login('valid', 'invalid', 'Invalid username or password')",
      "  end",
      "",
      "  it \"Valid login/password\" do",
      "    check_login('valid', 'valid', nil)",
      "  end",
      "end"
    ].join("\n")

    @scenario_with_datatable_rendered_with_uids = [
      "def check_login(login, password, expected)",
      "  \# Ensure the login process",
      "  fill_login(login)",
      "  fill_password(password)",
      "  press_enter",
      "  assert_error_is_displayed(expected)",
      "end",
      "",
      "def test_check_login_wrong_login_uida123",
      "  check_login('invalid', 'invalid', 'Invalid username or password')",
      "end",
      "",
      "def test_check_login_wrong_password_uidb456",
      "  check_login('valid', 'invalid', 'Invalid username or password')",
      "end",
      "",
      "def test_check_login_valid_loginpassword_uidc789",
      "  check_login('valid', 'valid', nil)",
      "end",
      ""
    ].join("\n")

    # Same than "scenario_with_datatable_rendered" but rendered with the option --split-scenarios
    @scenario_with_datatable_rendered_in_single_file = [
      "# encoding: UTF-8",
      "require 'spec_helper'",
      "require_relative 'actionwords'",
      "",
      "describe 'AProjectWithDatatables' do",
      "  include Actionwords",
      "",
      "",
      "  context \"check login\" do",
      "    def check_login(login, password, expected)",
      "      \# Ensure the login process",
      "      fill_login(login)",
      "      fill_password(password)",
      "      press_enter",
      "      assert_error_is_displayed(expected)",
      "    end",
      "",
      "    it \"Wrong login\" do",
      "      check_login('invalid', 'invalid', 'Invalid username or password')",
      "    end",
      "",
      "    it \"Wrong password\" do",
      "      check_login('valid', 'invalid', 'Invalid username or password')",
      "    end",
      "",
      "    it \"Valid login/password\" do",
      "      check_login('valid', 'valid', nil)",
      "    end",
      "  end",
      "end"
    ].join("\n")

    # In Hiptest, correspond to two scenarios in a project called 'My project'
    # scenario 'first scenario' do
    # end
    # scenario 'second scenario' do
    #   call 'my action word'
    # end
    @scenarios_rendered = [
      "# encoding: UTF-8",
      "require_relative 'actionwords'",
      "",
      "describe 'MyProject' do",
      "  include Actionwords",
      "",
      "  it 'first_scenario' do",
      "  end",
      "  it 'second_scenario' do",
      "    my_action_word",
      "  end",
      "end"].join("\n")

      @tests_rendered = [
       "# encoding: UTF-8",
       "require 'spec_helper'",
       "require_relative 'actionwords'",
       "",
       "describe 'MyTestProject' do",
       "  include Actionwords",
       "",
       "  it \"Login\" do",
       "    # The description is on ",
       "    # two lines",
       "    # Tags: myTag myTag:somevalue",
       "    visit('/login')",
       "    fill('user@example.com')",
       "    fill('s3cret')",
       "    click('.login-form input[type=submit]')",
       "    check_url('/welcome')",
       "  end",
       "",
       "  it \"Failed login\" do",
       "    # Tags: myTag:somevalue",
       "    visit('/login')",
       "    fill('user@example.com')",
       "    fill('notTh4tS3cret')",
       "    click('.login-form input[type=submit]')",
       "    check_url('/login')",
       "  end",
       "end"
      ].join("\n")

      @first_test_rendered = [
        "it \"Login\" do",
        "  # The description is on ",
        "  # two lines",
        "  # Tags: myTag myTag:somevalue",
        "  visit('/login')",
        "  fill('user@example.com')",
        "  fill('s3cret')",
        "  click('.login-form input[type=submit]')",
        "  check_url('/welcome')",
        "end"
      ].join("\n")

      @first_test_rendered_for_single_file = [
       "# encoding: UTF-8",
       "require 'spec_helper'",
       "require_relative 'actionwords'",
       "",
       "describe 'MyTestProject' do",
       "  include Actionwords",
       "",
       "",
       "  it \"Login\" do",
       "    # The description is on ",
       "    # two lines",
       "    # Tags: myTag myTag:somevalue",
       "    visit('/login')",
       "    fill('user@example.com')",
       "    fill('s3cret')",
       "    click('.login-form input[type=submit]')",
       "    check_url('/welcome')",
       "  end",
       "end"
      ].join("\n")

    # In hiptest
    # scenario 'reset password' do
    #   call given 'Page "url" is opened'(url='/login')
    #   call when 'I click on "link"'(link='Reset password')
    #   call then 'page "url" should be opened'(url='/reset-password')
    # end
    @bdd_scenario_rendered = [
      'it "Reset password" do',
      '  # Given Page "/login" is opened',
      '  page_url_is_opened(\'/login\')',
      '  # When I click on "Reset password"',
      '  i_click_on_link(\'Reset password\')',
      '  # Then Page "/reset-password" should be opened',
      '  page_url_should_be_opened(\'/reset-password\')',
      'end'
    ].join("\n")
  end

  context '<The test framework>' do
    it_behaves_like "a renderer" do
      let(:language) {'<My language>'}
      let(:framework) {'<The test framework>'}
    end
  end
end
