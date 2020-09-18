#!/bin/bash -xe
restart=$1
cd LOCATION_PATH
changed=0
git remote update && git status -uno | grep -q 'Your branch is behind' && changed=1
if [ $changed = 0 ] && [ "$restart" != "force" ]; then
    echo "Nothing to Pull! Going to restart the app"
elif [ $changed = 1 ] || [ "$restart" = "force" ]; then

        echo "Pulling lastest code from github"
        git pull

        changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"

        check_run() {
                echo "$changed_files" | grep --quiet "$1" && eval "$2"
        }

        # It's used to run `npm install` if package.json changed.
        check_run package.json "npm install"

        # Create necessary directories
        rm -rf dist

        # build the application
        node --max_old_space_size=8192 node_modules/@angular/cli/bin/ng build --prod --aot --vendor-chunk --common-chunk --delete-output-path --buildOptimizer

        # Copy the dist folder to nginx and restart the server
       cd /var/www/html/
        rm -rf angular
        mkdir angular
        cp -a SOURCE_PATH DESTINATION_PATH
else
        echo "Nothing to run."
fi

sudo service nginx restart

sleep 3s

restorecon -r /var/www/html

echo "Deployed successfully"
