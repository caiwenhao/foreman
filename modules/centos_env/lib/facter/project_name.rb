Facter.add(:project_name) do
  setcode do
    Facter::Util::Resolution.exec("awk -F'[@_]' '/PS1/ {print $2}' /root/.bashrc")
  end
end