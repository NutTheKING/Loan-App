import 'package:flutter/material.dart';

class CustomProfileHeaderWidget extends StatelessWidget {
  const CustomProfileHeaderWidget({super.key, this.name, this.phone, this.onEdit});

  final String? name;
  final String? phone;
  final Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blue.shade200,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 5),
              Text(phone ?? '', style: TextStyle(color: Colors.grey[700])),
              SizedBox(height: 8),
              TextButton(onPressed: onEdit, child: Text("Edit Profile")),
            ],
          ),
        ],
      ),
    );
  }
}
