# ForceUnspecified: Rack app redirects to a SAML IdP URL with changing NameIDPolicy Format in SAMLRequest to unspecified

- Before: `<samlp:NameIDPolicy AllowCreate='true' Format='urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'/>`
- After: `<samlp:NameIDPolicy AllowCreate='true' Format='urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified'/>`

Some IdP, e.g. Azure Active Directory, forces user's _true_ identifier even if an admin set customized User Identifier to the IdP, when a SAML request comes with `NameIDPolicy` Format=`emailAddress`. This is a simple Rack app that replaces all policies to `unspecified` before passing to IdP.

## Installation

```ruby
# Gemfile
gem 'force_unspecified'
```

```ruby
# config.ru
require 'force_unspecified'
run ForceUnspecified
```

## Usage

1. Set your RP to use `https://force_unspecified/ORIGINAL_URL` as a IdP SAML URL.
   - (where `force_unspecified` is your deployment URL of this app, and `ORIGINAL_URL` is your original IdP SAML URL)
   - e.g. `https://force_unspecified/https://login.example.org/SAML`
2. When RP sends a user to this app, this app changes `nameid-format` to `unspecified`, then redirects to the IdP.
3. Happiness

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/force_unspecified.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
