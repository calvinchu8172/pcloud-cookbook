fluent_base_image_repo = node['fluentd-base']['repository']
fluent_base_image_revision = node['fluentd-base']['revision']
aws_account_id = fluent_base_image_repo.split('.').first


execute 'login AWS ECR' do
  command "$(aws ecr get-login --region us-east-1 --registry-ids #{aws_account_id})"
end

execute 'pull fluent-base image from AWS ECR' do
  command "docker pull #{fluent_base_image_repo}:#{fluent_base_image_revision}"
end



