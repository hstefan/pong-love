#!/bin/sh
TITLE="MoonOfPong"
zip -9 -r $TITLE.love *.lua data/ hump/
mv ${TITLE}.love redist/$TITLE
cd redist/$TITLE
cat love.exe ${TITLE}.love > ${TITLE}.exe
cd ..
zip -r ${TITLE}.zip ${TITLE} -x $TITLE/love.exe
cp ${TITLE}.zip ~/Copy/Share/.

