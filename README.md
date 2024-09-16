# puppet-lint-stdlib_deprecations

[![ci](https://github.com/puppetlabs/puppet-lint-stdlib_deprecations/actions/workflows/nightly.yml/badge.svg)](https://github.com/puppetlabs/puppet-strings/actions/workflows/nightly.yml)
[![Gem Version](https://badge.fury.io/rb/puppet-lint-stdlib_deprecations.svg)](https://badge.fury.io/rb/puppet-lint-stdlib_deprecations)
[![Code Owners](https://img.shields.io/badge/owners-DevX--team-blue)](https://github.com/puppetlabs/puppet-lint-stdlib_deprecations/blob/main/CODEOWNERS)

A puppet-lint plugin to detect [puppetlabs/stdlib](https://forge.puppet.com/modules/puppetlabs/stdlib) deprecations including removed and non-namespaced functions and datatypes.

## Installation

Add this line to your modules's Gemfile:

```ruby
gem 'puppet-lint-stdlib_deprecations'
```

And then execute:

```bash
bundle install
```

Or install it with:

```bash
gem install puppet-lint-stdlib_deprecations
```

## Checks

This plugin includes two checks.

### stdlib_deprecated_functions

Scans your puppet code for instances of removed and non-namespaced functions in `puppetlabs/stdlib` v9.0.0+. The plugin will only flag functions removed, that do not have an exact replcacement in core Puppet (for example, `upcase` or `chomp`).

```puppet
class example_module::agent (
  String $ipaddress = '127.0.0.1'
) {
  $chomped = chomp('hello\n')

  if is_ip_address($ipaddress) {
    notice("${ipaddress} is an ipaddress!")
  }

  $size = size('hello')

  $escaped = batch_escape('echo "hello world"')
}
```

The above manifest will result in this console output:

```bash
puppet-lint path/to/file.pp

ERROR: Deprecated function found: 'is_ip_address' on line 6 (check: stdlib_deprecated_functions)
ERROR: Deprecated function found: 'size'. Use length() instead. on line 10 (check: stdlib_deprecated_functions)
WARNING: Deprecated function found: 'batch_escape'. Use stdlib::batch_escape instead. on line 12 (check: stdlib_deprecated_functions)
```

Notice, there is no output for the `chomp(..)` function call as there is a direct replacement in core Puppet, meaning the function will continue to work as expected.

* `is_ip_address` is flagged as an error, as this will require manual intervention from the user to update this instance to a suitable replacement.
* `size` is also flagged as an error was replaced by `length()` which is shipped with Puppet.
* `batch_escape` omits a warning, this is because the function call will continue to work (until later removed from [puppetlabs/stdlib](https://forge.puppet.com/modules/puppetlabs/stdlib)), as 'under the hood' puppet will call the namespaced function.

For functions which have a namespaced counterpart (like `batch_escape`) we can make use of puppet-lint's autocorrect functionality to automate the process of updating these function calls.

```puppet
class example_module::agent (
  String $ipaddress = ''
) {
...
  $escaped = batch_escape('echo "hello world"')
}
```

```bash
puppet-lint --fix path/to/file.pp
...
FIXED: Deprecated function found: 'batch_escape'. Use stdlib::batch_escape instead. on line 12 (check: stdlib_deprecated_functions)
...
```

And the updated code will look like:

```puppet
class example_module::agent (
  String $ipaddress = ''
) {
...
  $escaped = stdlib::batch_escape('echo "hello world"')
}

To disable this check, you can add `--no-stdlib_deprecated_functions-check` to your puppet-lint command line.

```bash
puppet-lint --no-stdlib_deprecated_functions-check path/to/file.pp
```

Or if you're calling puppet-lint via a Raketask, add this to your Rakefile:

```ruby
PuppetLint.configuration.send('disable_stdlib_deprecated_functions')
```

### stdlib_deprecated_datatypes

Checks for instances of the removed `Stdlib::Compat` datatypes in your manifests.

```puppet
class example_module::agent (
  String $ip = '127.0.0.1',
) {
  if ($ip =~ Stdlib::Compat::Ipv4) {
    notice("${ip} is an ip address!")
  }
}
```

When running this check, puppet-lint will flag this instance of `Stdlib::Compat::Ip_address` as an error.

```bash
puppet-lint /path/to/file.pp

ERROR: Removed data type found: 'Stdlib::Compat::Ipv4' on line 4 (check: stdlib_deprecated_datatypes)
```

What you should now use:

```puppet
class example_module::agent (
  String $ip = '127.0.0.1',
) {
  if ($ip =~ Stdlib::IP::Address) {
    notice("${ip} is an ip address!")
  }
}
```

Again, to disable this check you can add `--no-stdlib_deprecated_datatypes-check` to your puppet-lint command line.

```bash
puppet-lint  --no-stdlib_deprecated_datatypes-check /path/to/file.pp
```

Or by adding this line to your Rakefile (if calling the puppet-lint rake task).

```ruby
PuppetLint.configuration.send('disable_stdlib_deprecated_datatypes')
```

## License

This codebase is licensed under Apache 2.0. However, the open source dependencies included in this codebase might be subject to other software licenses such as AGPL, GPL2.0, and MIT.

## Development

If you run into an issue with this plugin or would like to request a feature you can raise a PR with your suggested changes. Keep in mind that this gem runs automated testing using GitHub Actions and we generally expect new contributions to pass these tests, as well as add additional testing in case of new features.

Alternatively, you can raise a Github issue with a feature request or bug reports. Every other Tuesday the DevX team holds office hours in the Puppet Community Slack, where you can ask questions about this and any other supported tools. This session runs at 15:00 (GMT) for about an hour.
