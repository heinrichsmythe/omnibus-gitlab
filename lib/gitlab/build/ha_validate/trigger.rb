require_relative '../trigger'
require_relative '../info'
require_relative "../../util.rb"

module Build
  class HA
    class ValidateTrigger
      extend Trigger

      PROJECT_PATH = 'gitlab-org/distribution/gitlab-provisioner'.freeze

      def self.get_project_path
        PROJECT_PATH
      end

      def self.ee_package_job_id
        Build::Info.fetch_pipeline_jobs(
          'gitlab-org%2Fomnibus-gitlab',
          Gitlab::Util.get_env('CI_PIPELINE_ID'),
          Gitlab::Util.get_env('HA_VALIDATE_TOKEN')
        ).select { |job| job['name'] == 'Trigger:package' }.first['id']
      end

      def self.get_params(image: nil)
        qa_image = image || "registry.gitlab.com/gitlab-org/omnibus-gitlab/gitlab-ee-qa:omnibus-#{Gitlab::Util.get_env('CI_COMMIT_SHA')}"
        {
          'ref' => 'master',
          'token' => Gitlab::Util.get_env('HA_VALIDATE_TOKEN'),
          'variables[QA_IMAGE]' =>  qa_image,
          'variables[OMNIBUS_JOB_ID]' => ee_package_job_id
        }
      end

      def self.get_access_token
        Gitlab::Util.get_env('GITLAB_BOT_MULTI_PROJECT_PIPELINE_POLLING_TOKEN')
      end
    end
  end
end
