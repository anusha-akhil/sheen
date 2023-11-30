import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sheenbakery/controller/controller.dart';
import 'package:sheenbakery/screen/reports/report_table.dart';

import '../../components/date_find.dart';

class PeakwiseTimeReport extends StatefulWidget {
  const PeakwiseTimeReport({super.key});

  @override
  State<PeakwiseTimeReport> createState() => _PeakwiseTimeReportState();
}

class _PeakwiseTimeReportState extends State<PeakwiseTimeReport> {
  DateFind dateFind = DateFind();
  String? todaydate;
  DateTime now = DateTime.now();

  DateTime selectedDate = DateTime.now();
  String? date;
  TextEditingController seacrh = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        date = DateFormat('dd-MM-yyyy').format(selectedDate);
        Provider.of<Controller>(context, listen: false)
            .getPeaktimeBranchwiseReport(context, date!);
      });
    } else {
      date = DateFormat('dd-MMM-yyyy').format(selectedDate);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todaydate = DateFormat('dd-MM-yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Peakwise Time Report",
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 3,
          vertical: 3,
        ),
        child: Consumer<Controller>(
          builder: (context, value, child) => Column(
            children: [
              Container(
                height: size.height * 0.08,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 20.0,
                      ),
                      child: Row(
                        children: [
                          // IconButton(
                          //     onPressed: () {
                          //       // String df;
                          //       // String tf;
                          //       dateFind.selectDateFind(context, "from date");
                          //       // if (value.fromDate == null) {
                          //       //   df = todaydate.toString();
                          //       // } else {
                          //       //   df = value.fromDate.toString();
                          //       // }
                          //       // if (value.todate == null) {
                          //       //   tf = todaydate.toString();
                          //       // } else {
                          //       //   tf = value.todate.toString();
                          //       // }
                          //       // Provider.of<Controller>(context, listen: false)
                          //       //     .historyData(context, splitted[0], "",
                          //       //         df, tf);
                          //     },
                          //     icon: Icon(
                          //       Icons.calendar_month,
                          //       // color: P_Settings.loginPagetheme,
                          //     )),
                          InkWell(
                              onTap: () {
                                _selectDate(context);
                              },
                              child: Icon(Icons.calendar_month)),
                          SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () {
                              // dateFind.selectDateFind(context, "from date");
                            },
                            child: Text(
                              date == null
                                  ? todaydate.toString()
                                  : date.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // dropDownCustom(size,""),
              ),
              value.isLoading
                  ? SpinKitCircle(
                      color: Colors.black,
                    )
                  : value.peakwise_time_report_list.length == 0
                      ? Container(
                          height: size.height * 0.6,
                          child: Center(
                            child: LottieBuilder.asset(
                              "assets/nodata.json",
                              height: size.height * 0.23,
                            ),
                          ),
                        )
                      : ReportTable(
                          list: value.peakwise_time_report_list,
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
