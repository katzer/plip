# Apache 2.0 License
#
# Copyright (c) 2018 Sebastian Katzer, appPlant GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'open3'
require 'tmpdir'
require 'securerandom'
require_relative '../mrblib/plip/version'

BIN = File.expand_path('../mruby/bin/plip', __dir__).freeze

NO_KEY  = { 'ORBIT_KEY' => nil }.freeze
BAD_KEY = { 'ORBIT_KEY' => 'bad file' }.freeze

assert('version [-v]') do
  output, status = Open3.capture2(BIN, '-v')

  assert_true status.success?, 'Process did not exit cleanly'
  assert_include output, PLIP::VERSION
end

assert('version [--version]') do
  output, status = Open3.capture2(BIN, '--version')

  assert_true status.success?, 'Process did not exit cleanly'
  assert_include output, PLIP::VERSION
end

assert('usage [-h]') do
  output, status = Open3.capture2(BIN, '-h')

  assert_true status.success?, 'Process did not exit cleanly'
  assert_include output, 'usage'
end

assert('usage [--help]') do
  output, status = Open3.capture2(BIN, '--help')

  assert_true status.success?, 'Process did not exit cleanly'
  assert_include output, 'usage'
end

assert('local [-l]') do
  _, output, status = Open3.capture3(BIN, '-r', 'remote', 'host')
  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'ArgumentError'

  _, output, status = Open3.capture3(BIN, '-l', 'l', '-r', 'r', 'h')
  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'NoFileError'
end

assert('remote [-r]') do
  _, output, status = Open3.capture3(BIN, '-l', 'local', 'host')

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'ArgumentError'
end

assert('no $ORBIT_KEY') do
  _, output, status = Open3.capture3(NO_KEY, BIN, '-d', '-l', 'l', '-r', 'r', 'host')

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'not set'
end

assert('bad $ORBIT_KEY') do
  _, output, status = Open3.capture3(BAD_KEY, BIN, '-d', '-l', 'l', '-r', 'r', 'host')

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'not found'
end

assert('no matcher') do
  _, output, status = Open3.capture3(BIN, '-d', '-l', 'l', '-r', 'r')

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'ArgumentError'
end

assert('unknown flag') do
  _, output, status = Open3.capture3(BIN, '-unknown')

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'unknown option'
end

assert('download') do
  output, status = Open3.capture2(BIN, '-d', '-r', __FILE__, 'localhost')

  skip('sshd not running') if ENV['OS'] == 'Windows_NT'

  assert_true status.success?, 'Process did not exit cleanly'
  assert_include output, 'appPlant'
end

assert('download [-l]') do
  path           = File.join(Dir.tmpdir, "plip.#{SecureRandom.hex(5)}")
  final_path     = "#{path}.localhost"
  output, status = Open3.capture2(BIN, '-d', '-l', path, '-r', __FILE__, 'localhost')

  skip('sshd not running') if ENV['OS'] == 'Windows_NT'

  assert_true status.success?, 'Process did not exit cleanly'
  assert_true output.empty?
  assert_true File.exist? final_path
  assert_equal File.read(__FILE__), File.read(final_path)

  File.delete(final_path)
end

assert('upload') do
  path           = File.join(Dir.tmpdir, "plip.#{SecureRandom.hex(5)}")
  output, status = Open3.capture2(BIN, '-l', __FILE__, '-r', path, 'localhost')

  skip('sshd not running') if ENV['OS'] == 'Windows_NT'

  assert_true status.success?, 'Process did not exit cleanly'
  assert_true output.empty?
  assert_true File.exist? path
  assert_equal File.read(__FILE__), File.read(path)
end

assert('fifa responds with empty list') do
  path           = File.join(Dir.tmpdir, "plip.#{SecureRandom.hex(5)}")
  final_path     = "#{path}.localhost"
  output, status = Open3.capture2(BIN, '-d', '-l', path, '-r', __FILE__, 'host')

  skip('sshd not running') if ENV['OS'] == 'Windows_NT'

  assert_true status.success?, 'Process did not exit cleanly'
  assert_true output.empty?
  assert_false File.exist? final_path
end

assert('fifa responds with error') do
  path           = File.join(Dir.tmpdir, "plip.#{SecureRandom.hex(5)}")
  final_path     = "#{path}.localhost"
  output, status = Open3.capture2e(BIN, '-d', '-l', path, '-r', __FILE__, 'error')

  skip('sshd not running') if ENV['OS'] == 'Windows_NT'

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'exit code'
  assert_false File.exist? final_path
end
