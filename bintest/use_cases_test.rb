# Write tests where the program should not fail
# this module is for testing the base/main use cases which are covered by this program
module UseCasesTest
  def test_successful
    output, error, status = Open3.capture3(PATH, BIN,
            "#{ENV["APP_HOME"]}/bintest/testFolder/bintest.sh",
            '$HOME/code/bintest/testFolder/test/bintest.sh', 'app')
      puts output
      puts error
      puts status

    assert_true status.success?, 'Process did not exit cleanly'
    assert_equal output, ""
  end


  # def test_successful_own
  #   output, error, status = Open3.capture3(PATH, BIN, '-own="root:root"',
  #           "#{ENV["APP_HOME"]}/bintest/testFolder/bintest.sh",
  #           '\$HOME/code/bintest/testFolder/test/bintest.sh', 'app')
  #   assert_true status.success?, 'Process did not exit cleanly'
  #   assert_equal output, ""
  # end

  def test_successful_mod
    output, error, status = Open3.capture3(PATH, BIN, '-mod="777"',
            "#{ENV["APP_HOME"]}/bintest/testFolder/bintest.sh",
            '$HOME/code/bintest/testFolder/test/bintest.sh', 'app')

    assert_true status.success?, 'Process did not exit cleanly'
    assert_equal output, ""
  end

end
