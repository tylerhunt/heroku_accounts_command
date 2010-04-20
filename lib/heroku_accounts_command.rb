module Heroku::Command
  class Accounts < BaseWithApp
    def index
    end

    def add
    end

    def switch
    end

    def remove
    end
  end
end

Heroku::Command::Help.group('Accounts') do |group|
  group.command('account', 'lists all accounts')
  group.command('account:add', 'adds a new account')
  group.command('account:switch', 'switches accounts')
  group.command('account:remove', 'removes a new account')
end
