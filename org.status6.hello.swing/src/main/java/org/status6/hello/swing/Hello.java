/*
 * Copyright (C) 2020 John Neffenger
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
package org.status6.hello.swing;

import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.SwingUtilities;

/**
 * A Java Swing application that prints "Hello World!" to standard output when
 * its button is pressed.
 */
public class Hello {

    /**
     * A method for unit testing.
     *
     * @return <code>true</code>
     */
    static boolean isTrue() {
        return true;
    }

    /**
     * Displays the main window.
     */
    private static void start() {
        JFrame frame = new JFrame("Hello Swing");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setLayout(new GridBagLayout());
        frame.setSize(800, 600);

        JButton button = new JButton("Say Hello World!");
        button.addActionListener(e -> System.out.println("Hello World!"));
        frame.add(button, new GridBagConstraints());

        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }

    /**
     * The entry point for this application.
     *
     * @param args command-line arguments
     */
    public static void main(String[] args) {
        SwingUtilities.invokeLater(Hello::start);
    }
}
