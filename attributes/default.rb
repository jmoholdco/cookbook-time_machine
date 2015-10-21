default['time_machine'] = {
  'name' => 'Time Machine',
  'path' => '/srv/time_machine',
  'spotlight' => true,
  'volume_size' => '512000',

  'avahi_package' => value_for_platform_family(
    'rhel' => 'avahi',
    'debian' => 'avahi-daemon'
  ),

  'homes' => {
    'enabled' => false,
    'regex' => '/home'
  }
}
