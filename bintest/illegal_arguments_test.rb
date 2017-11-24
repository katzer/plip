# This module fis or tests where the program becomes the correct number of arguments but
# where the arguments are illegal.
module IllegalArgumentsTest


  def test_illegal_flag
    output, error, status = Open3.capture3(PATH, BIN, '-waga=true', 'app')

    assert_include output, 'plip - Planet Impact Probe', 'Output was not correct'
    assert_true status.success?, 'Process did not exit cleanly'
  end

  def test_not_enough_tail
    output, error, status = Open3.capture3(PATH, BIN, '-mod="777"', '-own="root:root"', 'sutff/to/stuff', 'app')

    assert_include output, 'plip - Planet Impact Probe', 'Output was not correct'
    assert_true status.success?, 'Process did not exit cleanly'
  end

  def test_illegal_mod
    output, error, status = Open3.capture3(PATH, BIN, '-mod="888"',
            "#{ENV["APP_HOME"]}/bintest/testFolder/bintest.sh",
            '$HOME/code/bintest/testFolder/test/bintest.sh', 'app')

    assert_false status.success?, 'Process did exit cleanly'
    assert_include output, "Process exited with status 1 "
  end



  def test_not_enough_arguments
    output, error, status = Open3.capture3(PATH, BIN, '-d=true', 'app')

    assert_include output, 'plip - Planet Impact Probe', 'Output was not correct'
    assert_true status.success?, 'Process did not exit cleanly'
  end

end
