require 'fibby'
require 'ippon/validate'

module Forms
  Text = Fibby::Text
  DelegateForm = Fibby::DelegateForm
  StepError = Ippon::Validate::StepError
  V = Ippon::Validate::Builder
end