import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheenbakery/components/common_data.dart';

import '../components/network_connectivity.dart';

class Controller extends ChangeNotifier {
  String? fromDate;
  String? todate;
  TextEditingController camtController = TextEditingController();
  String? catSelected;
  List<Map<String, dynamic>> branch_list = [];
  List<Map<String, dynamic>> sale_report_list = [];
  List<Map<String, dynamic>> category_list = [];
  List fisttableHeader = [];
  List secndtablHeader = [];
  List<Map<String, dynamic>> sale_data = [];
  List<Map<String, dynamic>> coll_data = [];
  double total_csh = 0.00;
  List<Map<String, dynamic>> damage_list = [];
  ////////////////////////////////////////////////////////////////
  List<Map<String, dynamic>> itemwise_report_list = [];
  List<Map<String, dynamic>> peakwise_time_report_list = [];
  List<Map<String, dynamic>> damage_report_list = [];

  double sum = 0.0;
  int dmg_count = 0;
  bool isDashLoading = false;
  bool isDashDataLoading = false;
  bool isLoading = false;
  bool isSaveLoading = false;

  double difference = 0.00;
  String? last_s_dt;
  // customNotifier() {
  //   Stream.periodic(const Duration(seconds: 10)).listen((_) {
  //     ///fetch data
  //     Future<List<dynamic>>.delayed(const Duration(milliseconds: 500),
  //         () async {
  //       return someFunction();
  //     });
  //   });
  //   // notifyListeners();
  // }
  geInitialization(BuildContext context, String fdate) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          Uri url = Uri.parse("$apiurl/load_dashboard.php");
          Map body = {
            'f_date': fdate,
          };
          isDashLoading = true;
          notifyListeners();
          http.Response response = await http.post(
            url,
            body: body,
          );
          final map = jsonDecode(response.body);
          print("---item${map}");

          branch_list.clear();
          for (var item in map) {
            double d = double.parse(item["branch_sale"]);
            String amt = d.toStringAsFixed(2);
            Map<String, dynamic> m = {
              "branch_id": item["branch_id"],
              "branch_name": item["branch_name"],
              "branch_sale": amt,
              "last_sync": item["last_sync"]
            };
            // double ite=double.parse(item);

            // String i=ite.toStringAsFixed(2);
            branch_list.add(m);
          }
          isDashLoading = false;
          notifyListeners();
          loadDashboard(context, fdate, "");
        } catch (e) {
          print(e);
          // return null;
          return [];
        }
      }
    });
  }

  ////////////////////////////////////
  loadDashboard(BuildContext context, String f_date, String type) async {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          Uri url = Uri.parse("$apiurl/load_dashboard.php");
          int dura = 10;
          if (type == "init") {
            print("hahhh");
            isDashLoading = true;
            notifyListeners();
          }
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("date", f_date);

          Stream.periodic(Duration(minutes: 3)).listen((_) {
            Future<List<dynamic>>.delayed(const Duration(milliseconds: 500),
                () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? fdate = prefs.getString("date");
              Map body = {
                'f_date': fdate,
              };
              print("ggbody------$body");
              http.Response response = await http.post(
                url,
                body: body,
              );
              final map = jsonDecode(response.body);
              branch_list.clear();
              for (var item in map) {
                double d = double.parse(item["branch_sale"]);
                String amt = d.toStringAsFixed(2);
                Map<String, dynamic> m = {
                  "branch_id": item["branch_id"],
                  "branch_name": item["branch_name"],
                  "branch_sale": amt,
                  "last_sync": item["last_sync"]
                };
                // double ite=double.parse(item);

                // String i=ite.toStringAsFixed(2);
                branch_list.add(m);
                // branch_list.add(item);
              }
              notifyListeners();
              if (type == "init") {
                isDashLoading = false;
                notifyListeners();
              }
              notifyListeners();
              print("branch_list------$branch_list");
              return branch_list;
              // notifyListeners();
            });
          });
        } catch (e) {
          print(e);
          // return null;
          return [];
        }
      }
    });
  }

///////////////////////////////////////////////////////////////////////////////
  getDashboardDetails(BuildContext context, String br_id, String f_date) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          Uri url = Uri.parse("$apiurl/load_details.php");
          isDashDataLoading = true;
          notifyListeners();
          Map body = {
            'branch_id': br_id,
            'f_date': f_date,
          };
          print("dash-------$body");
          http.Response response = await http.post(url, body: body);
          var map = jsonDecode(response.body);
          print("map-det--$map");
          sale_data.clear();
          for (var item in map["sale_data"]) {
            sale_data.add(item);
          }
          if (map["total_csh"] != null) {
            print("ttttt");
            total_csh = double.parse(map["total_csh"]);
          } else {
            total_csh = 0.00;
          }
          coll_data.clear();
          if (map["colectn"].length > 0) {
            for (var item in map["colectn"]) {
              coll_data.add(item);
            }

            difference = double.parse(coll_data[0]["prev_blnc"]);
          } else {
            // difference = 0.00;
            difference = total_csh;
          }

          dmg_count = int.parse(map["dmg_cnt"]);
          last_s_dt = map["last_s_dt"].toString();
          notifyListeners();
          sum = 0.0;
          for (int i = 0; i < sale_data.length; i++) {
            sum = double.parse(sale_data[i]["p_amount"]) + sum;
          }
          isDashDataLoading = false;
          notifyListeners();

          print("dashDeatilsList--------${sale_data}");
          notifyListeners();
        } catch (e) {
          print(e);
          // return null;
          return [];
        }
      }
    });
  }

  //////////////////////////////////////////////
  getDamageData(BuildContext context, String br_id, String f_date) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          Uri url = Uri.parse("$apiurl/load_dmg_details.php");
          // isDashDataLoading = true;
          // notifyListeners();
          Map body = {
            'branch_id': br_id,
            'f_date': f_date,
          };
          print("dash-------$body");
          isLoading = true;
          notifyListeners();
          http.Response response = await http.post(url, body: body);
          var map = jsonDecode(response.body);
          print("damage ---$map");
          damage_list.clear();
          for (var item in map) {
            damage_list.add(item);
          }
          isLoading = false;
          notifyListeners();
        } catch (e) {
          print(e);
          // return null;
          return [];
        }
      }
    });
  }

  /////////////////////////////////////////////////////////
  saveCollection(BuildContext context, String br_id, String f_date, String camt,
      String pamt, String flag) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          Uri url = Uri.parse("$apiurl/save_colection.php");
          // isDashDataLoading = true;
          // notifyListeners();
          Map body = {
            'branch_id': br_id,
            'camnt': camt,
            'pamt': pamt,
            'f_date': f_date,
            "flag": flag
          };
          print("save collection body-------$body");
          isSaveLoading = true;
          notifyListeners();
          http.Response response = await http.post(url, body: body);
          var map = jsonDecode(response.body);
          print("save collection map ---$map");
          isSaveLoading = false;
          notifyListeners();
          if (map["flag"] == 0) {
            Fluttertoast.showToast(
                msg: map["msg"],
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0);
            camtController.clear();
            // difference = 0.00;
            getDashboardDetails(context, br_id, f_date);
          }
          // damage_list.clear();
          // for (var item in map) {
          //   damage_list.add(item);
          // }
          notifyListeners();
        } catch (e) {
          print(e);
          // return null;
          return [];
        }
      }
    });
  }

  calculateDifference(double total_cash, double prev_amt, double camt) {
    double previous_bal = total_cash - prev_amt;
    difference = previous_bal - camt;
    print("jbjhxfbjhfgb----$difference---");
    notifyListeners();
  }

///////////////////////////////////////////////////////////////
  getSaleReport(BuildContext context, String br_id, String f_date) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          Uri url = Uri.parse("$apiurl/load_staff_sale.php");
          // isDashDataLoading = true;
          // notifyListeners();
          Map body = {
            'branch_id': br_id,
            'f_date': f_date,
          };
          print("sale report body-------$body");
          isLoading = true;
          notifyListeners();
          http.Response response = await http.post(url, body: body);
          var map = jsonDecode(response.body);
          print("sale report---$map");
          sale_report_list.clear();
          for (var item in map) {
            sale_report_list.add(item);
          }
          isLoading = false;
          notifyListeners();
        } catch (e) {
          print(e);
          // return null;
          return [];
        }
      }
    });
  }

  //////////////////////////////////////////////////////
  getCategory(BuildContext context) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          // category_list = [
          //   {
          //     "cat_id": "1",
          //     "cat_name": "biscuit",
          //   },
          //   {
          //     "cat_id": "2",
          //     "cat_name": "cake",
          //   },
          //   {
          //     "cat_id": "3",
          //     "cat_name": "chips",
          //   },
          //   {
          //     "cat_id": "4",
          //     "cat_name": "snacks",
          //   },
          //   // {
          //   //   "cat_uid": "1",
          //   //   "cat_name": "biscuit",
          //   // },
          // ];

          Uri url = Uri.parse("$apiurl/get_category.php");

          Map body = {
            // 'branch_id': br_id,
            // 'f_date': f_date,
          };
          print("category body-------$body");
          isLoading = true;
          notifyListeners();
          http.Response response = await http.post(
            url,
          );
          var map = jsonDecode(response.body);
          print("category-$map");
          category_list.clear();
          for (var item in map) {
            category_list.add(item);
          }
          isLoading = false;
          notifyListeners();
        } catch (e) {
          print(e);
          // return null;
          return [];
        }
      }
    });
  }

/////////////////////////////////////////////////////////////////////////////////
  setDropdowndata(String s) {
    for (int i = 0; i < category_list.length; i++) {
      if (category_list[i]["cat_id"] == s) {
        catSelected = category_list[i]["cat_name"];
      }
    }
    print("s------$s");
    notifyListeners();
  }

  /////////////////////////////////////////////////////////////////////////////
  getItemwisereport(
      BuildContext context, String? cat, String fdate, String to_date) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          Map body = {};
          Uri url = Uri.parse("$apiurl/get_report.php");
          if (cat == null || cat!.isEmpty || cat == " " || cat == "null") 
          {
            print("cat ull");
            body = {
              'cat': " ",
              'f_date': fdate,
              't_date': to_date,
              "type": "1"
            };
          } 
          else
          {
            body = {
              'cat': cat,
              'f_date': fdate,
              't_date': to_date,
              "type": "1"
            };
          }

          print("report body-------$body");
          isLoading = true;
          notifyListeners();
          http.Response response = await http.post(url, body: body);
          var map = jsonDecode(response.body);
          print("itemwise  report---$map");
          itemwise_report_list.clear();

          if (map != null && map.length > 0) {
            for (var item in map) {
              itemwise_report_list.add(item);
            }
            secndtablHeader = itemwise_report_list[0].keys.toList();
            fisttableHeader = [
              itemwise_report_list[0].keys.first.toUpperCase()
            ];
            notifyListeners();

            secndtablHeader.removeAt(0);
            notifyListeners();
          }
          print("secndtablHeader-  --${secndtablHeader}");
          isLoading = false;
          notifyListeners();
        } catch (e) {
          print(e);
          // return null;
          return [];
        }
      }
    });
  }

/////////////////////////////////////////////////////////////////////////
  getDamageCountReport(
      BuildContext context, String cat, String fdate, String to_date) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          Uri url = Uri.parse("$apiurl/get_report.php");

          Map body = {
            'cat': " ",
            'f_date': fdate,
            't_date': to_date,
            "type": "3"
          };

          print("report body-------$body");
          isLoading = true;
          notifyListeners();
          http.Response response = await http.post(url, body: body);
          var map = jsonDecode(response.body);
          print("damage count  report---$map");
          if (map != null && map.length > 0) {
            damage_report_list.clear();
            for (var item in map) {
              damage_report_list.add(item);
            }
            secndtablHeader = damage_report_list[0].keys.toList();
            fisttableHeader = [damage_report_list[0].keys.first.toUpperCase()];
            notifyListeners();

            secndtablHeader.removeAt(0);
            notifyListeners();
          }

          print("secndtablHeader-  --${secndtablHeader}");
          isLoading = false;
          notifyListeners();
        } catch (e) {
          print(e);
          // return null;
          return [];
        }
      }
    });
  }

///////////////////////////////////////////////////////////////
  getPeaktimeBranchwiseReport(BuildContext context, String fdate) {
    NetConnection.networkConnection(context).then((value) async {
      if (value == true) {
        try {
          Uri url = Uri.parse("$apiurl/get_report.php");
          Map body = {
            'cat': " ",
            'f_date': fdate,
            't_date': fdate,
            "type": "2"
          };
          print("report body-------$body");
          isLoading = true;
          notifyListeners();
          http.Response response = await http.post(url, body: body);
          var map = jsonDecode(response.body);
          print("peakwise  report---$map");
          peakwise_time_report_list.clear();
          if (map != null && map.length > 0) {
            for (var item in map) {
              peakwise_time_report_list.add(item);
            }
            secndtablHeader = peakwise_time_report_list[0].keys.toList();
            fisttableHeader = [
              peakwise_time_report_list[0].keys.first.toUpperCase()
            ];
            notifyListeners();
            secndtablHeader.removeAt(0);
            notifyListeners();
          }
          isLoading = false;
          notifyListeners();
        } catch (e) {
          print(e);
          // return null;
          return [];
        }
      }
    });
  }
///////////////////////////////////////////////////////////////////////////////
  setDate(String date1, String date2) {
    fromDate = date1;
    todate = date2;
    print("gtyy----$fromDate----$todate");
    notifyListeners();
  }
}
