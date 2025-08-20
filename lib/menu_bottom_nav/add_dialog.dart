import 'package:flutter/material.dart';
import 'package:gym_plan_app/add_screen/AddMealScreen.dart';
import 'package:gym_plan_app/add_screen/AddWorkoutScreen.dart';


class AddDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Thêm", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              "Hãy chọn thêm lịch tập hoặc thêm bữa ăn",
              style: TextStyle(color: Colors.grey[400]),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddWorkoutScreen()));
                    if (result == true) {
                      Navigator.of(context).pop('workout');
                    }
                  },
                  child: Text("LỊCH TẬP", style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.orange : const Color(0xFFFF6A00))),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddMealScreen()));
                    if (result == true) {
                      Navigator.of(context).pop('meal');
                    }
                  },
                  child: Text("BỮA ĂN", style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.orange : const Color(0xFFFF6A00))),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("HỦY", style: TextStyle(color: Theme.of(context).brightness == Brightness.light ? Colors.orange : const Color(0xFFFF6A00))),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
