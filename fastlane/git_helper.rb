module Fastlane
  module Actions
    module SharedValues
      GIT_BRANCH_ENV_VARS = %w(GIT_BRANCH BRANCH_NAME TRAVIS_BRANCH BITRISE_GIT_BRANCH CI_BUILD_REF_NAME CI_COMMIT_REF_NAME WERCKER_GIT_BRANCH BUILDKITE_BRANCH APPCENTER_BRANCH CIRCLE_BRANCH).reject do |branch|
        # Removing because tests break on CircleCI
        Helper.test? && branch == "CIRCLE_BRANCH"
      end.freeze
    end


    def self.git_branch
      return self.git_branch_name_using_HEAD if FastlaneCore::Env.truthy?('FL_GIT_BRANCH_DONT_USE_ENV_VARS')
  
      env_name = SharedValues::GIT_BRANCH_ENV_VARS.find { |env_var| FastlaneCore::Env.truthy?(env_var) }
      ENV.fetch(env_name.to_s) do
      self.git_branch_name_using_HEAD
      end
    end
  
    # Returns the checked out git branch name or "HEAD" if you're in detached HEAD state
    def self.git_branch_name_using_HEAD
      # Rescues if not a git repo or no commits in a git repo
      Actions.sh("git rev-parse --abbrev-ref HEAD", log: false).chomp
    rescue => err
      UI.verbose("Error getting git branch: #{err.message}")
      nil
    end

    # Get the author email of the last git commit
    def self.git_author_email
      s = last_git_commit_formatted_with('%ae')
      return s if s.to_s.length > 0
      return nil
    end

    # Gets the last git commit information formatted into a String by the provided
    # pretty format String. See the git-log documentation for valid format placeholders
    def self.last_git_commit_formatted_with(pretty_format, date_format = nil)
      command = %w(git log -1)
      command << "--pretty=#{pretty_format}"
      command << "--date=#{date_format}" if date_format
      Actions.sh(*command.compact, log: false).chomp
    rescue
      nil
    end
  end
end