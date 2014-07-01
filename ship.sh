#!/bin/sh

zip -9 -r pong.love *.lua data/ hump/
mv pong.love redist/pong
cd redist/pong
cat love.exe pong.love > Pong.exe
cd ..
zip -r pong.zip pong -x pong/love.exe
cp pong.zip ~/Copy/Share/.

