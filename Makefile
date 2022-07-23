push:
	git tag --delete latest
	git add -u
	git commit -m "Update action"
	git push
