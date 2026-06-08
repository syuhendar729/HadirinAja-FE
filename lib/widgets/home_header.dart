import 'package:flutter/material.dart';

import '../utils/datetime_helper.dart';

class HomeHeader extends StatelessWidget {
    const HomeHeader({super.key});

    @override
    Widget build(BuildContext context) {
        return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
                Container(
                    width: 100,
                    height: 100,

                    decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        border: Border.all(
                            color:
                                const Color(
                              0xFF001F54,
                            ),
                            width: 4,
                        ),
                    ),

                    child: CircleAvatar(
                        backgroundColor:
                            Colors.grey[300],

                        child: const Icon(
                            Icons.person,
                            size: 50,
                        ),
                    ),
                ),

                const SizedBox(width: 20),

                Expanded(
                    child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                            const Text(
                                'Syuhada Rantisi',

                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                ),
                            ),

                            const SizedBox(
                                height: 4),

                            const Text(
                                'NIM: 122140092',
                            ),

                            const SizedBox(
                                height: 16),

                            Text(
                                DateTimeHelper
                                    .formattedDate(),
                            ),

                            const SizedBox(
                                height: 4),

                            Text(
                                DateTimeHelper
                                    .formattedTime(),

                                style:
                                    const TextStyle(
                                  fontSize: 24,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                            ),
                        ],
                    ),
                ),
            ],
        );
    }
}