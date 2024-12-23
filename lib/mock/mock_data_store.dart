// lib/mock/mock_data_store.dart

class MockDataStore {
  static final Map<String, Map<String, dynamic>> features = {
    "Pitch": {
      "name": "Pitch",
      "composites": [],
      "transformations": [],
      "startingPoints": {},
      "howManyValues": {},
      "isTemplate": true,
    },
    "Time": {
      "name": "Time",
      "composites": [],
      "transformations": [],
      "startingPoints": {},
      "howManyValues": {},
      "isTemplate": true,
    },
    "Duration": {
      "name": "Duration",
      "composites": [],
      "transformations": [],
      "startingPoints": {},
      "howManyValues": {},
      "isTemplate": true,
    },
    "FeatureA": {
      "name": "FeatureA",
      "composites": ["Pitch", "Time"],
      "transformations": [
        {
          "name": "Add",
          "args": [1],
          "subFeatureName": "Pitch"
        },
        {
          "name": "Mul",
          "args": [2],
          "subFeatureName": "Pitch"
        },
        {
          "name": "Add",
          "args": [3],
          "subFeatureName": "Time"
        }
      ],
      "startingPoints": {"Pitch": null, "Time": null},
      "howManyValues": {"Pitch": null, "Time": null},
    },
    "FeatureB": {
      "name": "FeatureB",
      "composites": ["Duration", "FeatureA"],
      "transformations": [
        {
          "name": "Add",
          "args": [2],
          "subFeatureName": "Duration"
        },
        {
          "name": "Mul",
          "args": [3],
          "subFeatureName": "Duration"
        }
      ],
      "startingPoints": {"Duration": null, "FeatureA": null},
      "howManyValues": {"Duration": null, "FeatureA": null},
    },
  };

  static final Map<String, Map<String, dynamic>> transformations = {
    "Add": {
      "name": "Add",
      "argsCount": 1,
      "description": "Adds a constant to the input index",
    },
    "Mul": {
      "name": "Mul",
      "argsCount": 1,
      "description": "Multiplies the input index by a constant",
    },
    "Nop": {
      "name": "Nop",
      "argsCount": 0,
      "description": "No operation",
    },
  };

  static final Map<String, Map<String, dynamic>> conditions = {
    "ConditionA": {
      "name": "ConditionA",
      "description": "Triggers when input > 5",
    },
    "ConditionB": {
      "name": "ConditionB",
      "description": "Triggers when input is even",
    },
  };

  static final Map<String, Map<String, dynamic>> performativeTransactions = {
    "PT1": {
      "name": "PT1",
      "description": "A basic performative transaction",
      "feature": "FeatureB",
      "condition": "ConditionA",
    },
    "PT2": {
      "name": "PT2",
      "description": "A complex performative transaction",
      "feature": "FeatureA",
      "condition": "ConditionB",
    },
  };
}
