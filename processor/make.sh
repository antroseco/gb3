cd ~/gb3
git reset --hard HEAD
git clean -f
git checkout remote-push
cd ~/gb3/processor/source/softwareblink
make
make install
cd ~/gb3/processor
make
