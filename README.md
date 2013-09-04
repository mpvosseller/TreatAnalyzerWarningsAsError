TreatAnalyzerWarningsAsError
============================

This script can be used in Xcode to "treat analyzer warnings as errors" for Xcode 5.

It was originally developed by Otto Schnurr
http://stackoverflow.com/users/148076/otto

and posted on stackoverflow.com here:
http://stackoverflow.com/questions/5033417/how-to-treat-warnings-from-clang-static-code-analysis-as-errors-in-xcode-3


Configuration:
- Enable the "Write Link Map File" build setting
- Add a new "Run Script Build Phase" after the "Link Binary With Libraries" phase
- Copy and paste the contents of the included script into the Script section
