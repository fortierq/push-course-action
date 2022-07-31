#!/bin/ash

REPO=$2
TOKEN=$3
USER=$4
CLONE_DIR=$(mktemp -d)
git clone "https://$USER:$TOKEN@github.com/$USER/$REPO.git" $CLONE_DIR
rm -rf $CLONE_DIR/files

img() {
    img=$(dirname $file)/img
    if [ -d $img ]; then
        cp -r $img $CLONE_DIR/$(dirname $file)
    fi
}

ipynb() {
    mkdir -p $CLONE_DIR/$(dirname $file)
    img
    if [[ $file == *.ipynb ]]; then
        jupyter nbconvert $file --to ipynb --output $CLONE_DIR/$file --allow-errors \
        --TagRemovePreprocessor.enabled=True \
        --TagRemovePreprocessor.remove_input_tags hide \
        --TagRemovePreprocessor.remove_cell_tags cor
    else
        cp $file "$CLONE_DIR/"$(dirname $file)
    fi
}

ipynb_cor() {
    img
    cor=${file%.*}_cor.${file#*.}
    if [[ $file == *.ipynb ]]; then
        jupyter nbconvert $file --to ipynb --output $CLONE_DIR/$file --allow-errors \
        --TagRemovePreprocessor.enabled=True \
        --TagRemovePreprocessor.remove_input_tags hide
    else
        cp $file "$CLONE_DIR/"$(dirname $file)
    fi
}

while read file; do
    echo "Processing $file"
    if [ ! -f $CLONE_DIR/$file ]; then
        ipynb
    fi
done < student.txt

while read file; do
    cor=${file%.*}_cor.${file#*.}
    if [ ! -f $CLONE_DIR/$file ]; then
        ipynb_cor
    fi
done < cor.txt

cd $CLONE_DIR
git config user.name 'github-actions[bot]'
git config user.email 'github-actions[bot]@users.noreply.github.com'
git add .
git commit -m "$1"
git push "https://$USER:$TOKEN@github.com/$USER/$REPO.git" --set-upstream main
