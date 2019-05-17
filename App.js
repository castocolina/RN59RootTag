/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, { Component } from "react";
import { AppState, Platform, StyleSheet, Text, View } from "react-native";
const { name: cmpName } = require("./package");

const instructions = Platform.select({
  ios: "Press Cmd+R to reload,\n" + "Cmd+D or shake for dev menu",
  android:
    "Double tap R on your keyboard to reload,\n" +
    "Shake or press menu button for dev menu"
});

type Props = {};
export default class App extends Component<Props> {
  state = {
    appState: AppState.currentState
  };

  constructor() {
    super();
    if (!this.compId) {
      this.compId = Math.floor(Math.random() * 100) + 1;
    }
    this.compName = cmpName;
  }

  componentDidMount() {
    const { compId, compName } = this;
    console.info(compId, compName, "componentDidMount");
    AppState.addEventListener("change", this._handleAppStateChange);
  }

  componentWillUnmount() {
    const { compId, compName } = this;
    console.info(compId, compName, "componentWillUnmount");
    AppState.removeEventListener("change", this._handleAppStateChange);
  }

  _handleAppStateChange = nextAppState => {
    const { compId, compName } = this;
    const { appState } = this.state;
    console.info(compId, compName, appState, nextAppState);

    if (appState.match(/inactive|background/) && nextAppState === "active") {
      console.log(compId, compName, "App has come to the foreground!");
    }
    this.setState({ appState: nextAppState });
  };

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>Welcome to React Native!</Text>
        <Text style={styles.instructions}>To get started, edit App.js</Text>
        <Text style={styles.instructions}>{instructions}</Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F5FCFF"
  },
  welcome: {
    fontSize: 20,
    textAlign: "center",
    margin: 10
  },
  instructions: {
    textAlign: "center",
    color: "#333333",
    marginBottom: 5
  }
});
