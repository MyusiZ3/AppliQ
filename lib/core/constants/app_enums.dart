enum EmploymentType {
  fullTime('Full Time'),
  internship('Internship'),
  contract('Contract'),
  partTime('Part Time'),
  freelance('Freelance');

  final String label;
  const EmploymentType(this.label);

  static EmploymentType fromString(String val) {
    return EmploymentType.values.firstWhere(
      (e) => e.label.toLowerCase() == val.trim().toLowerCase(),
      orElse: () => EmploymentType.fullTime,
    );
  }
}

enum WorkSystem {
  onSite('On-site'),
  hybrid('Hybrid'),
  wfh('WFH');

  final String label;
  const WorkSystem(this.label);

  static WorkSystem fromString(String val) {
    return WorkSystem.values.firstWhere(
      (e) => e.label.toLowerCase() == val.trim().toLowerCase(),
      orElse: () => WorkSystem.onSite,
    );
  }
}

enum JobPortal {
  linkedIn('Linked In'),
  jobStreet('JobStreet'),
  glints('Glints'),
  kitaLulus('KitaLulus'),
  website('Website'),
  instagram('Instagram'),
  lainnya('Lainnya');

  final String label;
  const JobPortal(this.label);

  static JobPortal fromString(String val) {
    return JobPortal.values.firstWhere(
      (e) => e.label.toLowerCase() == val.trim().toLowerCase(),
      orElse: () => JobPortal.linkedIn,
    );
  }
}

enum ApplicationStatus {
  applied('Applied'),
  interview('Interview'),
  offering('Offering'),
  accepted('Accepted'),
  rejected('Rejected'),
  noResponse('No Response');

  final String label;
  const ApplicationStatus(this.label);

  static ApplicationStatus fromString(String val) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.label.toLowerCase() == val.trim().toLowerCase(),
      orElse: () => ApplicationStatus.applied,
    );
  }
}
