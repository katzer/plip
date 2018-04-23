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

def gem_config(conf)
  conf.gem __dir__
  conf.cc.flags += %w[-DMBEDTLS_THREADING_PTHREAD -DMBEDTLS_THREADING_C]
end

MRuby::Build.new do |conf|
  toolchain ENV.fetch('TOOLCHAIN', :clang)

  conf.enable_bintest
  conf.enable_debug
  conf.enable_test

  gem_config(conf)
end

MRuby::Build.new('x86_64-pc-linux-gnu-glibc-2.12') do |conf|
  toolchain :clang

  [conf.cc, conf.cxx, conf.linker].each do |cc|
    cc.flags << '-Oz'
  end

  gem_config(conf)
end

MRuby::CrossBuild.new('i686-pc-linux-gnu-glibc-2.12') do |conf|
  toolchain :clang

  [conf.cc, conf.cxx, conf.linker].each do |cc|
    cc.flags += %w[-Oz -m32]
  end

  gem_config(conf)
end
