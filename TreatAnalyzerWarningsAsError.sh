error_count=0

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
  local analysis_directory=$TARGET_TEMP_DIR/StaticAnalyzer/$CURRENT_VARIANT/$CURRENT_ARCH
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
