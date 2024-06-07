# Fastlane Action for slack message

Action for sending message with incoming webhook app in slack. Supports both simplified template and user customized block kit message.

# Example Output

This action will generate and send a message to Slack that looks like this:
<img width="697" alt="스크린샷 2024-06-07 오후 8 02 05" src="https://github.com/nighttwo1/fastlane-slack-message/assets/43779571/dad071b8-c458-42df-913e-cba8dfde3d4f">

# Usage

Here is an example of how to use this action in your `Fastfile`:

### 1. Use predefiend template

```ruby
lane :post_to_slack do
  slack_message(
    title: "새로운 안드로이드 앱이 배포되었습니다! 🚀",
    sub_title: "Checkout for new version of android app!",
    webhook_url: "https://hooks.slack.com/services/...",
    payload: {
      "버전" => "0.1.10",
      "패키지명" => "com.nighttwo1.slackmsg",
    },
    default_payloads: [:git_branch, :git_author, :release_date],
    footer: "테스트 후 피드백은 언제든지 환영합니다. 앱 사용 중 문제가 발생하거나 개선 사항이 있다면 메시지를 남겨주시면 감사하겠습니다.",
  )
end
```

### 2. Use customed block kit message

```ruby
lane :post_to_slack_with_custom_body do
  slack_message(
    webhook_url: "https://hooks.slack.com/services/...",
    custom_body: '{
      "blocks": [
          {
            "type": "header",
            "text": {
              "type": "plain_text",
              "text": "새로운 안드로이드 앱이 배포되었습니다! 🚀",
              "emoji": true
            }
          },
          {
            "type": "section",
            "text": {
              "type": "plain_text",
              "text": "Checkout for new version of android app!",
              "emoji": true
            }
          },
          {
            "type": "section",
            "fields": [
              {
                "type": "mrkdwn",
                "text": "*버전:* `0.1.10`"
              },
              {
                "type": "mrkdwn",
                "text": "*패키지명:* `com.nighttwo1.slackmsg`"
              },
              {
                "type": "mrkdwn",
                "text": "*Release Date:* `2024-06-05`"
              }
            ]
          },
          {
            "type": "divider"
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "테스트 후 피드백은 언제든지 환영합니다. 앱 사용 중 문제가 발생하거나 개선 사항이 있다면 메시지를 남겨주시면 감사하겠습니다."
            }
          }
        ]
      }'
  )
end
```

# Parameters

| Key                | Description                                                                                                              | Environment Variable                | Default                        | Type   | Optional |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ | ----------------------------------- | ------------------------------ | ------ | -------- |
| `title`            | The title displayed on the Slack message.                                                                                | `FL_SLACK_MESSAGE_TITLE`            | `새로운 메시지`                | String | No       |
| `sub_title`        | The subtitle displayed on the Slack message.                                                                             | `FL_SLACK_MESSAGE_SUB_TITLE`        |                                | String | Yes      |
| `webhook_url`      | The Incoming WebHook URL for your Slack group.                                                                           | `FL_SLACK_MESSAGE_WEBHOOK_URL`      |                                | String | No       |
| `payload`          | A hash containing additional information to be displayed in the message.                                                 | `FL_SLACK_MESSAGE_PAYLOAD`          | `{}`                           | Hash   | No       |
| `default_payloads` | An array containing default information to be displayed in the message.                                                  | `FL_SLACK_MESSAGE_DEFAULT_PAYLOADS` | `['git_branch', 'git_author']` | Array  | No       |
| `footer`           | Additional message displayed at the bottom of the Slack message.                                                         | `FL_SLACK_MESSAGE_FOOTER`           |                                | String | Yes      |
| `custom_body`      | A complete custom body for the Slack message in JSON format. If this is provided, it will override the other parameters. | `FL_SLACK_MESSAGE_CUSTOM_BODY`      |                                | String | Yes      |
