#!/bin/bash
# NUCLEARMISTAKE 2014
#    STEP YOUR BASH UP, SON
[ ! $ANDROID_BUILD_TOP ] && echo "ANDROID_BUILD_TOP not defined. source build/envsetup.sh before running $0" && exit 1
mkdir -p $ANDROID_BUILD_TOP/CHANGELOGS/
if [ $FORCE_BUILD_DATE ]; then
  Y=${FORCE_BUILD_DATE:4:2}
  M=${FORCE_BUILD_DATE:0:2}
  D=${FORCE_BUILD_DATE:2:2}
  d=$Y$M$D
  logd=$M$D$Y
else
  d=`date +"%y%m%d"`
  logd=`date +"%m%d%y"`
fi
CHANGELOGOUT=$ANDROID_BUILD_TOP/CHANGELOGS/cmremix_$logd
echo "" > $CHANGELOGOUT
ln -sf $CHANGELOGOUT $ANDROID_BUILD_TOP/CHANGES.LOG
logit()
{
    lines=`cat /tmp/currentlog | wc -l`
    if [ $lines ] && [ $lines -gt 0 ]; then        
        project=`git remote -v | grep $remote | grep fetch | sed "s/^$remote[ \t][ \t]*//g" | sed 's/[ \t]*(fetch)//g'`
        echo "**** $project ****" | tee -a $CHANGELOGOUT
        head -n 50 /tmp/currentlog | tee -a $CHANGELOGOUT
        if [ $lines -gt 50 ]; then
            echo "* ... `expr $lines - 50` lines truncated ... *"
        fi
        echo " " | tee -a $CHANGELOGOUT
    fi
}
getbranch()
{
   (repo info 2>/dev/null || true)  | head -n 5 | grep Manifest\ merge\ branch --color=never | sed 's/.*: //g'
}
version=`getbranch`
newversion=HEAD
if [ $1 ]; then lastversion=$1; fi
if [ $2 ]; then newversion=$2; fi
repo forall -c pwd | while read PROJECT; do
cd $PROJECT
remote=`git branch -a | grep remotes/m/$version | sed 's/.* -> //g' | sed 's/\/.*//g' | sort -u`;
if [ `git remote -v | grep $remote | grep -v aosp | wc -l` -gt 0 ]; then
    if [ ! $lastversion ]; then
      prev=`git tag | sort -uh | grep -x '[0-9][0-9]*' | grep -v "$d"  | tail -n 1`
      if [ $prev ] && [ `echo $prev | wc -w` -eq 1 ]; then
        lastversion="$prev"
      elif [ `git tag | sort -uh | grep cmremix_ | wc -l` -gt 0 ]; then
        lastversion="`git tag | sort -uh | grep cmremix_ | tail -n 1`"
      else
        lastversion=m/$version
      fi
    fi
    echo "CHANGELOG SINCE $lastversion... TAGGING $d"
    if [ $lastversion ]; then
        git log $lastversion..$newversion --no-merges --format="%h : %s <%an> %ar" > /tmp/currentlog
    else
        git log --no-merges --format="%h : %s <%an> %ar" > /tmp/currentlog
    fi
    logit
    git tag -d $d >& /dev/null
    git tag $d
fi
done

cp $ANDROID_BUILD_TOP/CHANGELOGS/cmremix_$logd $OUT/system/etc/CHANGELOG-cmR.txt
cp $ANDROID_BUILD_TOP/CHANGELOGS/cmremix_$logd $OUT/Changelog.txt
repo forall -pc git log --reverse --since=1.week.ago > Weekly_Changelog
cp $ANDROID_BUILD_TOP/Weekly_Changelog $ANDROID_BUILD_TOP/CHANGELOGS/Weekly_Changelog.md
