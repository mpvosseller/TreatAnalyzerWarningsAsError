##
## This script was originaly developed by Otto
## http://stackoverflow.com/users/148076/otto
##
## and posted on stackoverflow.com here:
## http://stackoverflow.com/questions/5033417/how-to-treat-warnings-from-clang-static-code-analysis-as-errors-in-xcode-3
##
## IMPORTANT: You eeded to enable the "Write Link Map File" build setting for this script to work
##
##

error_count=0

## The static analyzer appears to run with the first architecture listed in ARCHS (which isn't always equal to $CURRENT_ARCH)
## This occurs when for example we build a fat universal binary ("armv7 armv7s")
## In this example the static analyzer runs and outputs to armv7 directory but when this script is run $CURRENT_ARCH is set to armv7s
## So when looking for the static analysis results we now use the first architecture listed in $ARCHS
archs_array=($ARCHS)
analyzer_arch=${archs_array[0]}

##

function verify_clang_analysis_at_path()
{
  local analysis_path=$1
  local plist_tool=/usr/libexec/PlistBuddy
  local diagnostics=$($plist_tool -c "print diagnostics" $analysis_path)

  if [[ $diagnostics != $'Array {\n}' ]]
  then
    ((error_count++))
  fi
}

function verify_clang_analysis_for_object_file()
{
  local object_file=$1
  local analysis_directory=$TARGET_TEMP_DIR/StaticAnalyzer/$PROJECT_NAME/$TARGET_NAME/$CURRENT_VARIANT/$analyzer_arch
  local analysis_path=$analysis_directory/${object_file%.*}.plist

  # if this object file corresponds to a source file that clang analyzed...
  if [ -e $analysis_path ]
  then
    verify_clang_analysis_at_path $analysis_path
  fi
}

##

object_directory=$OBJECT_FILE_DIR-$CURRENT_VARIANT/$CURRENT_ARCH
object_path_pattern=${object_directory}'/\(.\)\+\.o$'

index_pattern='\[[[:space:]0-9]*\][[:space:]]'

object_paths=$( 
  grep $object_path_pattern $LD_MAP_FILE_PATH | sed s/$index_pattern//
)

##

for object_path in $object_paths 
do
  object_file=${object_path##*/}
  verify_clang_analysis_for_object_file $object_file
done

if [ $error_count -gt 0 ]
then
   echo "Clang static code analysis failed for" $error_count "source file(s)."
fi

exit $error_count
