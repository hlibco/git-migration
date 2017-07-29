# Git Migration (Gitlab -> Github Private Repos)

Follow the prompts to migrate your GitLab repos to GitHub.

## Migrate

If you want to mirror only some of your repos (but not all of them), you should manually define them:


`migrate.hs`
```
repos=(
)
```

The `migrate.sh` intends to mirror GitLab repos associated to *groups / organizations*. To migrate personal repos you might have to change the API url `https://gitlab.com/api/v4/groups/${GROUP}/projects`. 

```
chmod a+x ./migrate.sh
./migrate.sh
```


## Update remote origin after mirroring repos

Follow the prompts to finish this process.

```
chmod a+x ./update.sh
./update.sh
```
