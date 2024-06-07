module Fastlane
  module Actions
    module SharedValues
      SLACK_MESSAGE_CUSTOM_VALUE = :SLACK_MESSAGE_CUSTOM_VALUE
    end

    require 'uri'
    require 'net/http'

    class SlackMessageAction < Action
      def self.run(params)
        webhook_url = params[:webhook_url]
        payload_json = ""
        if params[:custom_body]
          payload_json = params[:custom_body]
        else
          payload_json = self.generate_slack_message(params)
        end

        uri = URI.parse(webhook_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/json'})
        request.body = payload_json

        response = http.request(request)
        if response.code.to_i == 200
          UI.message("Successfully sent message to Slack")
        else
          UI.error("Failed to send message to Slack: #{response.body}")
          raise FastlaneException.new(response.body)
        end
        
        
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        # UI.message("Parameter API Token: #{params[:api_token]}")

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::SLACK_MESSAGE_CUSTOM_VALUE] = "my_val"
      end

      def self.generate_slack_message(options)
        header = {
          type: "header",
          text: {
            type: "plain_text",
            text: options[:title],
            emoji: true
          }
        }

        sub_title = {
          type: "section",
          text: {
            type: "plain_text",
            text: options[:sub_title],
            emoji: true
          }
        }

        content = {
          type: "section",
          fields: []
        }
        content[:fields] = options[:payload].map do |key, value|
          {
            type: "mrkdwn",
            text: "*#{key.to_s}:* `#{value.to_s}`"
          }
        end

        default_content = {
          type: "section",
          fields: []
        }

        default_payloads = ->(payload_name) {options[:default_payloads].map(&:to_sym).include?(payload_name.to_sym)}
        # git branch
        if Actions.git_branch && default_payloads[:git_branch]
          default_content[:fields] << {
            type: "mrkdwn",
            text: "*Git Branch:* `#{Actions.git_branch}`"
          }
        end

        # git_author
        if Actions.git_author_email && default_payloads[:git_author]
          if FastlaneCore::Env.truthy?('FASTLANE_SLACK_HIDE_AUTHOR_ON_SUCCESS') && options[:success]
          # We only show the git author if the build failed
          else
            default_content[:fields] << {
              type: "mrkdwn",
              text: "*Git Author:* `#{Actions.git_author_email}`"
            }
          end
        end
        
        #release_date
        if default_payloads[:release_date]
          default_content[:fields] << {
              type: "mrkdwn",
              text: "*Release Date:* `#{Time.new.to_s}`"
            }
        end

        divider = {
          type: "divider"
        }

        footer = {
          type: "section",
          text: {
            type: "mrkdwn",
            text: options[:footer]
          }
        }

        post_message = {
          blocks: []
        }
        post_message[:blocks].push(header)
        post_message[:blocks].push(sub_title)
        post_message[:blocks].push(content)
        post_message[:blocks].push(default_content)
        post_message[:blocks].push(divider)
        post_message[:blocks].push(footer)

        post_message.to_json
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'A short description with <= 80 characters of what this action does'
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        'You can use this action to do cool things...'
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :title,
                                       # The name of the environment variable
                                       env_name: 'FL_SLACK_MESSAGE_TITLE',
                                       # a short description of this parameter
                                       description: 'Title displayed on Slack message',
                                       default_value: "새로운 메시지"),
          FastlaneCore::ConfigItem.new(key: :sub_title,
                                       # The name of the environment variable
                                       env_name: 'FL_SLACK_MESSAGE_SUB_TITLE',
                                       # a short description of this parameter
                                       description: 'Sub title displayed on Slack message',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :webhook_url,
                                       # The name of the environment variable
                                       env_name: 'FL_SLACK_MESSAGE_WEBHOOK_URL',
                                       # a short description of this parameter
                                       description: 'Incoming WebHook for your Slack group',
                                       verify_block: proc do |value|
                                        UI.user_error!("Invalid URL, must start with https://") unless value.start_with?("https://")
                                      end),
          FastlaneCore::ConfigItem.new(key: :payload,
                                       # The name of the environment variable
                                       env_name: 'FL_SLACK_MESSAGE_PAYLOAD',
                                       # a short description of this parameter
                                       description: 'Add additional information to this post. payload must be a hash containing any key with any value',
                                       default_value: {},
                                       type: Hash),
          FastlaneCore::ConfigItem.new(key: :default_payloads,
                                       # The name of the environment variable
                                       env_name: 'FL_SLACK_MESSAGE_DEFAULT_PAYLOADS',
                                       # a short description of this parameter
                                       description: 'Specifies default payloads to include. Pass an empty array to suppress all the default payloads',
                                       default_value: ['git_branch', 'git_author'],
                                       type: Array),
          FastlaneCore::ConfigItem.new(key: :footer,
                                       # The name of the environment variable
                                       env_name: 'FL_SLACK_MESSAGE_FOOTER',
                                       # a short description of this parameter
                                       description: 'Additional message',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :custom_body,
                                       # The name of the environment variable
                                       env_name: 'FL_SLACK_MESSAGE_CUSTOM_BODY',
                                       # a short description of this parameter
                                       description: 'Additional message',
                                       optional: true),
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['SLACK_MESSAGE_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ['Your GitHub/Twitter Name']
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
