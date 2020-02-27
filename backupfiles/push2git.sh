latest_file=$(ls -t | head -n 1)
scp -rp "$latest_file" backupfiles
git add backupfiles
git commit -m "push backup on $(date)"
git push
