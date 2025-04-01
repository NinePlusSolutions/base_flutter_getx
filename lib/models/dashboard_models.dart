class MonthlyEmployeeData {
  final int employeeBegin;
  final int employeeNewRecruits;
  final int employeeLeave;
  final int employeeEnd;

  MonthlyEmployeeData({
    required this.employeeBegin,
    required this.employeeNewRecruits,
    required this.employeeLeave,
    required this.employeeEnd,
  });

  factory MonthlyEmployeeData.fromJson(Map<String, dynamic> json) {
    return MonthlyEmployeeData(
      employeeBegin: json['employeeBegin'] ?? 0,
      employeeNewRecruits: json['employeeNewRecruits'] ?? 0,
      employeeLeave: json['employeeLeave'] ?? 0,
      employeeEnd: json['employeeEnd'] ?? 0,
    );
  }
}

class SeniorityData {
  final int lessOneYear;
  final int oneYear;
  final int twoYear;
  final int threeYear;
  final int forYear;
  final int greaterFiveYear;

  SeniorityData({
    required this.lessOneYear,
    required this.oneYear,
    required this.twoYear,
    required this.threeYear,
    required this.forYear,
    required this.greaterFiveYear,
  });

  factory SeniorityData.fromJson(Map<String, dynamic> json) {
    return SeniorityData(
      lessOneYear: json['lessOneYear'] ?? 0,
      oneYear: json['oneYear'] ?? 0,
      twoYear: json['twoYear'] ?? 0,
      threeYear: json['threeYear'] ?? 0,
      forYear: json['forYear'] ?? 0,
      greaterFiveYear: json['greaterFiveYear'] ?? 0,
    );
  }
}

class DepartmentData {
  final int totalEmployee;
  final int totalIntership;
  final int total;

  DepartmentData({
    required this.totalEmployee,
    required this.totalIntership,
    required this.total,
  });

  factory DepartmentData.fromJson(Map<String, dynamic> json) {
    return DepartmentData(
      totalEmployee: json['totalEmployee'] ?? 0,
      totalIntership: json['totalIntership'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}

class DashboardData {
  final Map<String, MonthlyEmployeeData> monthlyData;
  final SeniorityData seniorityData;
  final Map<String, DepartmentData> departmentData;

  DashboardData({
    required this.monthlyData,
    required this.seniorityData,
    required this.departmentData,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    Map<String, MonthlyEmployeeData> monthlyMap = {};
    (json['monthlyData'] as Map<String, dynamic>).forEach((key, value) {
      monthlyMap[key] = MonthlyEmployeeData.fromJson(value);
    });

    Map<String, DepartmentData> departmentMap = {};
    (json['departmentData'] as Map<String, dynamic>).forEach((key, value) {
      departmentMap[key] = DepartmentData.fromJson(value);
    });

    return DashboardData(
      monthlyData: monthlyMap,
      seniorityData: SeniorityData.fromJson(json['seniorityData']),
      departmentData: departmentMap,
    );
  }

  static DashboardData getSampleData() {
    return DashboardData(
      monthlyData: {
        "1": MonthlyEmployeeData(
          employeeBegin: 2,
          employeeNewRecruits: 1,
          employeeLeave: 3,
          employeeEnd: 1,
        ),
        "2": MonthlyEmployeeData(
          employeeBegin: 2,
          employeeNewRecruits: 1,
          employeeLeave: 1,
          employeeEnd: 1,
        ),
      },
      seniorityData: SeniorityData(
        lessOneYear: 1,
        oneYear: 0,
        twoYear: 0,
        threeYear: 0,
        forYear: 0,
        greaterFiveYear: 0,
      ),
      departmentData: {
        "Bộ phận .Net": DepartmentData(
          totalEmployee: 2,
          totalIntership: 12,
          total: 14,
        ),
        "Manager": DepartmentData(
          totalEmployee: 2,
          totalIntership: 5,
          total: 7,
        ),
      },
    );
  }
}
