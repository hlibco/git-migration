# Update remote origin after mirroring repos
# chmod a+x ./update.sh
# ./update.sh

set -e
clear
echo 'Update remote origin after mirroring repos'
echo '------------------------------------------ \n'

# Config
root=~/git
mirror="git@github.com:username"
criteria="username"

# Prompts
read -p "What is your work folder? (${root}) " input_root
read -p "Where is your new git? (${mirror}) " input_mirror
read -p "Only update repos where origin contains: (${criteria}) " input_criteria

root="${input_root:-$root}"
mirror="${input_mirror:-$mirror}"
criteria="${input_criteria:-$criteria}"

update() {
  path=$1
  echo "$path"

  # Change into newly created repo directory
  cd "${path}"

  if ! git ls-files >& /dev/null; then
    echo "Not in git \n"
    return
  fi

  repo=$(basename -s .git `git config --get remote.origin.url`)
  echo "Repo -> ${repo}"

  r=($(git remote -v | sed -n 1p))
  remote=${r[1]}
  echo "Remote (current) -> ${remote}"

  if [[ ! $remote == *"${criteria}"* ]]; then
    echo "Do not update! \n"
    return
  fi

  origin="${mirror}/$repo.git"

  # Set push URL to the mirror location
  if git remote set-url origin $origin
  then
    echo "Origin (updated) -> ${origin}"
  else
    echo "Origin (failed) -> ${origin}"
  fi

  # Back to work folder
  cd .. && echo " \n"
}

# Iterate work folder seeking for git repos to update
folders=$(ls -d ${root}/*/)
for folder in ${folders[@]}
do
  update $folder
done
