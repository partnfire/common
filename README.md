# common
You want to add pod 'PFCommon', '~> 1.0.9' similar to the following to your Podfile:

target 'MyApp' do
  pod 'PFCommon', '~> 1.0.9'
end
Then run a pod install inside your terminal, or from CocoaPods.app.

Alternatively to give it a test run, run the command:

pod try PFCommon
