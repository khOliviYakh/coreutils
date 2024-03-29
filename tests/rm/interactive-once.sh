#!/bin/sh
# Test the -I option added to coreutils 6.0

# Copyright (C) 2006-2013 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

. "${srcdir=.}/tests/init.sh"; path_prepend_ ./src
print_ver_ rm

mkdir -p dir1-1 dir2-1 dir2-2 || framework_failure_
touch file1-1 file2-1 file2-2 file2-3 file3-1 file3-2 file3-3 file3-4 \
  || framework_failure_
echo y > in-y || framework_failure_
echo n > in-n || framework_failure_
rm -f out err || framework_failure_


# The prompt has a trailing space, and no newline, so an extra
# 'echo .' is inserted after each rm to make it obvious what was asked.

echo 'one file, no recursion' > err || fail=1
rm -I file1-* < in-n >> out 2>> err || fail=1
echo . >> err || fail=1
test -f file1-1 && fail=1

echo 'three files, no recursion' >> err || fail=1
rm -I file2-* < in-n >> out 2>> err || fail=1
echo . >> err || fail=1
test -f file2-1 && fail=1
test -f file2-2 && fail=1
test -f file2-3 && fail=1

echo 'four files, no recursion, answer no' >> err || fail=1
rm -I file3-* < in-n >> out 2>> err || fail=1
echo . >> err || fail=1
test -f file3-1 || fail=1
test -f file3-2 || fail=1
test -f file3-3 || fail=1
test -f file3-4 || fail=1

echo 'four files, no recursion, answer yes' >> err || fail=1
rm -I file3-* < in-y >> out 2>> err || fail=1
echo . >> err || fail=1
test -f file3-1 && fail=1
test -f file3-2 && fail=1
test -f file3-3 && fail=1
test -f file3-4 && fail=1

echo 'one file, recursion, answer no' >> err || fail=1
rm -I -R dir1-* < in-n >> out 2>> err || fail=1
echo . >> err || fail=1
test -d dir1-1 || fail=1

echo 'one file, recursion, answer yes' >> err || fail=1
rm -I -R dir1-* < in-y >> out 2>> err || fail=1
echo . >> err || fail=1
test -d dir1-1 && fail=1

echo 'multiple files, recursion, answer no' >> err || fail=1
rm -I -R dir2-* < in-n >> out 2>> err || fail=1
echo . >> err || fail=1
test -d dir2-1 || fail=1
test -d dir2-2 || fail=1

echo 'multiple files, recursion, answer yes' >> err || fail=1
rm -I -R dir2-* < in-y >> out 2>> err || fail=1
echo . >> err || fail=1
test -d dir2-1 && fail=1
test -d dir2-2 && fail=1

cat <<\EOF > expout || fail=1
EOF
cat <<\EOF > experr || fail=1
one file, no recursion
.
three files, no recursion
.
four files, no recursion, answer no
rm: remove 4 arguments? .
four files, no recursion, answer yes
rm: remove 4 arguments? .
one file, recursion, answer no
rm: remove 1 argument recursively? .
one file, recursion, answer yes
rm: remove 1 argument recursively? .
multiple files, recursion, answer no
rm: remove 2 arguments recursively? .
multiple files, recursion, answer yes
rm: remove 2 arguments recursively? .
EOF

compare expout out || fail=1
compare experr err || fail=1

Exit $fail
