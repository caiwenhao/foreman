Facter.add(:bashrc_ps1) do
  setcode do
    Facter::Util::Resolution.exec("awk -F'[@ ]' '/PS1/ {print $3}' /root/.bashrc")
  end
end