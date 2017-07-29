# Migrate repos from GitLab to Github Private
# chmod a+x ./migrate.sh
# ./migrate.sh

set -e
clear
echo 'Migrate repos from GitLab to GitHub Private'
echo '------------------------------------------- \n'

# List of repos to migrate (if null, all remote repos will be migrated)
repos=(
)

# Config
TOKEN="https://gitlab.com/profile/personal_access_tokens"
GROUP="your_group_name_on_gitlab"
ORGANIZATION="your_organization_name_on_github"

# Prompts
read -p "What is your private token (GitLab)? (${TOKEN}) " input_token
read -p "What is your group name (GitLab)? (${GROUP}) " input_group
read -p "What is your organization name (GitHub)? (${ORGANIZATION}) " input_organization

TOKEN="${input_token:-$TOKEN}"
GROUP="${input_group:-$GROUP}"
ORGANIZATION="${input_organization:-$ORGANIZATION}"

if [[ ${#repos[@]} == 0 ]]
then
  repos=$(curl "https://gitlab.com/api/v4/groups/${GROUP}/projects?private_token=${TOKEN}&per_page=99" | \
  grep -o "\https://gitlab.com/${GROUP}/[-_A-Za-z]*\.git" | \
  xargs -L1 basename | \
  awk -F '.' '{print $1}'
  )
fi

migrate() {
  repo=$1
  echo "\nCloning $repo ..."

  # Clone the repo from GitLab using the `--mirror` option
  git clone --mirror git@gitlab.com:${GROUP}/$repo.git

  # Change into newly created repo directory
  cd ${repo}.git

  # Fetch all of the remote branches and tags:
  git fetch origin

  # View all "old repo" local and remote branches:
  git branch -a

  # Create GitHub repo
  hub create ${ORGANIZATION}/${repo}.git -p || true

  # Set push URL to the mirror location
  echo "Set --push origin >> git@github.com:${ORGANIZATION}/${repo}.git"
  git remote set-url --push origin git@github.com:${ORGANIZATION}/${repo}.git

  # Push to GitHub using the `--mirror` option.  The `--no-verify` option skips any hooks.
  echo "Push to origin >> ${repo}.git"
  git push --no-verify --mirror origin

  # To periodically update the repo on GitHub with what you have in GitLab
  # git fetch -p origin
  # git push --no-verify --mirror

  # Remove repo folder
  cd .. && rm -rf ${repo}.git
}

for repo in ${repos[@]}
do
  # echo "Repo: ${repo}"
  migrate $repo
done
