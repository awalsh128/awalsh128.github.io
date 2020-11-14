---
title: Fish Notes
date: '2020-11-13T00:00:00.000-07:00'
tags:
- git
modified_time: '2020-11-13T00:00:00.000-07:00'
excerpt: "Fish notes giving commonly used commands and some handy special workflows."
toc: true
---

## Bash Differences

These are differences between Bash and Fish in terms of syntax. Below are links
and a reference table.

*   [Fish translation table](https://en.wikipedia.org/wiki/Friendly_interactive_shell#bash.2Ffish_Translation_table)

Action / Thing               | Bash                   | Fish
---------------------------- | ---------------------- | ------------------------
Brace literal                | `{}`                   | `'{}'`
Command substitution         | `$(command)`           | `(command)`
Exit code of last command    | `$?`                   | `$status`
Logical AND between commands | `command1 && command2` | `command1; and command2`
PID of self                  | `$$`                   | `%self`
PID of last                  | `command $!`           | `%last`
Redirect STDERR command      | `2>/dev/null command`  | `^/dev/null`
                             | `command 2>&1`         | `command 2>&1`
Redirect STDOUT              | `command >/dev/null`   | `command >/dev/null`
Run command in background    | `command &`            | `command &`
Unset variable               | `unset foo`            | `set -e foo`
Variable assignment          | `foo=bar`              | `set foo bar`

## If-Then-Else

```sh
if test "$fish" = "flounder"
  echo FLOUNDER
end
```

```sh
if test "$number" -gt 5
  echo $number is greater than five
else
  echo $number is five or less
end
```

```sh
if test -e /etc/hosts  # -e switch is a file/directory/symlink exists test
  echo Positive
else
  echo Negative
end
```

## For Loops

```sh
# List file expansion
for file in *.txt
  cp $file $file.bak
end

# Number seuqnce expansion
for x in (seq 5)
  touch file_$x.txt
end

# Inline
for x in "a" "b" "c"; echo $x; done;
```

## Functions

When fish encounters a command, it attempts to autoload a function for that
command, by looking for a file with the name of that command in
`~/.config/fish/functions/`.

```sh
function ll
    ls -lh $argv
end
```

### Scope

```sh
function foo
    set baz 'foo foo'
end

function bar
    set --local baz 'bar bar'
    foo  # Doesn't change the value of baz; stays in its own scope.
    echo $baz
end

bar
```

## Lists / Arrays

Warning: All indexing is one based.

### Slices

```sh
# Standard
echo (seq 3)             # -> 1 2 3
echo (seq 10)[1 2 3]     # -> 1 2 3
echo (seq 10)[2..5]      # -> 2 3 4 5
echo (seq 10)[2..5 1..3] # -> 2 3 4 5 1 2 3
echo (seq 4)[2..-1]      # -> 2 3 4
echo (seq 3)[-1..1]      # -> 3 2 1
echo (seq 5)[-3..-1]     # -> 3 4 5
```

### Variable Index

```sh
set i 2
echo (seq 5)[$i]     # Fails
set sequence (seq 5) # Must be written in 2 lines.
echo $sequence[$i]   # -> 2
```

## Switch

```sh
set text # ...
switch (text)
  case foo
      echo foo foo
  case bar
      echo bar bar
  case baz
      echo baz baz
  case '*'
      echo default
end
```

## Test / Conditionals

### I/O

```sh
test -b $f  # is a block device.
test -c $f  # is a character device.
test -d $f  # is a directory
test -e $f  # exists
test -f $f  # is a regular file.
test -g $f  # has the set-group-ID bit set.
test -G $f  # exists and has the same group ID as the current user.
test -L $f  # is a symbolic link.
test -O $f  # exists and is owned by the current user.
test -p $f  # is a named pipe.
test -r $f  # is marked as readable.
test -s $f  # size($f) > 0
test -S $f  # is a socket.
test -t $f  # file descriptor $f is a terminal (TTY).
test -u $f  # has the set-user-ID bit set.
test -w $f  # is marked as writable; note that this does not check if the filesystem is read-only.
test -x $f  # is an executable.
```

### Logical

```sh
test $cond1 -a $cond2  # AND
test $cond1 -o $cond2  # OR
test ! $cond1          # NEGATE

# Requires escaping ( and ) to avoid being interpreted as command substitution.
test \($cond1 -a $cond2\) -o \($cond3 -a $cond4\)  # Connective
```

### Numbers

Note: Only integers are supported. For more complex mathematical operations,
including fractions, the env program may be useful. Consult the documentation
for your operating system.

```sh
test $x -eq $y  # ==
test $x -ne $y  # !=
test $x -gt $y  # >
test $x -ge $y  # >=
test $x -lt $y  # <
test $x -le $y  # <=
```

### Strings

```sh
test $s = $t  # ==
test $s != $t # !=
test -n $s    # != 0
test -z $s    # == 0
```

## While

```sh
while true
  echo "foo forever"
end
```

## Resources

*   [Fish Documentation](https://fishshell.com/docs/current/) - The latest in
    the official documentation for the shell.