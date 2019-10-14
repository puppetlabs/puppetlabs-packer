# Class to relax the security policies using ayohrling/local_security_policy
#
class windows_template::policies::security_policies ()
{
  local_security_policy { 'Maximum password age':
    ensure       => present,
    policy_value => '-1',
  }

  local_security_policy { 'Minimum password age':
    ensure       => present,
    policy_value => '0',
  }

  local_security_policy { 'Minimum password length':
    ensure       => present,
    policy_value => '0',
  }

  local_security_policy { 'Password must meet complexity requirements':
    ensure       => present,
    policy_value => '0',
  }

  local_security_policy { 'Enforce password history':
    ensure       => present,
    policy_value => '0',
  }

  local_security_policy { 'Store passwords using reversible encryption':
    ensure       => present,
    policy_value => '0',
  }
}
