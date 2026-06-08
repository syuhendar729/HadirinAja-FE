// file: lib/widgets/action_card.dart

import 'package:flutter/material.dart';

class ActionCard extends StatelessWidget {
    final String title;
    final String subtitle;
    final IconData icon;
    final VoidCallback onTap;

    const ActionCard({
        super.key,
        required this.title,
        required this.subtitle,
        required this.icon,
        required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onTap: onTap,

            child: Container(
                padding:
                    const EdgeInsets.all(16),

                decoration: BoxDecoration(
                    border: Border.all(),

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                ),

                child: Row(
                    children: [
                        Container(
                            width: 70,
                            height: 70,

                            decoration:
                                BoxDecoration(
                              color: Colors.blue
                                  .withOpacity(
                                0.1,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),

                            child: Icon(
                                icon,
                                size: 36,
                            ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                    Text(
                                        title,

                                        style:
                                            const TextStyle(
                                          fontSize:
                                              18,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                    ),

                                    const SizedBox(
                                        height: 4),

                                    Text(
                                        subtitle),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}