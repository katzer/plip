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
require_relative '../mrblib/plip/version'

BINARY  = File.expand_path('../mruby/bin/plip', __dir__)

ORB_KEY = { 'ORBIT_KEY' => 'Rakefile' }.freeze
BAD_KEY = { 'ORBIT_KEY' => 'bad file' }.freeze

assert('version [-v]') do
  output, status = Open3.capture2(BINARY, '-v')

  assert_true status.success?, 'Process did not exit cleanly'
  assert_include output, PLIP::VERSION
end

assert('version [--version]') do
  output, status = Open3.capture2(BINARY, '--version')

  assert_true status.success?, 'Process did not exit cleanly'
  assert_include output, PLIP::VERSION
end

assert('usage [-h]') do
  output, status = Open3.capture2(BINARY, '-h')

  assert_true status.success?, 'Process did not exit cleanly'
  assert_include output, 'usage'
end

assert('usage [--help]') do
  output, status = Open3.capture2(BINARY, '--help')

  assert_true status.success?, 'Process did not exit cleanly'
  assert_include output, 'usage'
end

assert('local [-l]') do
  _, output, status = Open3.capture3(ORB_KEY, BINARY, '-r', 'remote', 'host')
  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'ArgumentError'

  _, output, status = Open3.capture3(ORB_KEY, BINARY, '-l', 'l', '-r', 'r', 'h')
  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'NoFileError'
end

assert('remote [-r]') do
  _, output, status = Open3.capture3(ORB_KEY, BINARY, '-l', 'local', 'host')

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'ArgumentError'
end

assert('missing $ORBIT_KEY') do
  _, output, status = Open3.capture3(BINARY, '-d', '-l', 'l', '-r', 'r', 'host')

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'not set'
end

assert('bad $ORBIT_KEY') do
  _, output, status = Open3.capture3(BAD_KEY, BINARY, '-d', '-l', 'l', '-r', 'r', 'host')

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'NoFileError'
end

assert('missing matcher') do
  _, output, status = Open3.capture3(ORB_KEY, BINARY, '-d', '-l', 'l', '-r', 'r')

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'ArgumentError'
end

assert('unknown flag') do
  _, output, status = Open3.capture3(BINARY, '-unknown')

  assert_false status.success?, 'Process did exit cleanly'
  assert_include output, 'unknown option'
end
