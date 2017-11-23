# This module fis or tests where the program becomes the correct number of arguments but
# where the arguments are illegal.
module IllegalArgumentsTest


  def test_not_enough_arguments
    output, error, status = Open3.capture3(PATH, BIN, '-d=true', 'app')

    assert_include output, 'plip - Planet Impact Probe', 'Output was not correct'
    assert_true status.success?, 'Process did not exit cleanly'
  end

end
