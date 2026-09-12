# F-Droid Submission Status & Tracker

> **Last Updated**: 2026-09-12 (Automated check & remediation)  
> **Application**: CheckerChecks  
> **Package ID**: `com.checkerchecks.checkerchecks`  
> **Repository**: [thisscribe000/CheckerChecks](https://github.com/thisscribe000/CheckerChecks)

---

## 1. Official F-Droid RFP Tracker

- **GitLab RFP Issue**: [fdroid/rfp#4383](https://gitlab.com/fdroid/rfp/-/issues/4383)
- **Work Item Link**: [https://gitlab.com/fdroid/rfp/-/work_items/4383](https://gitlab.com/fdroid/rfp/-/work_items/4383)
- **Status**: **Opened** (In Maintainer Queue — `To do`)
- **Submitted By**: `paperlinkos`
- **Submission Date**: 2026-09-12 06:55 UTC
- **Recipe Target**: [metadata/com.checkerchecks.checkerchecks.yml](https://github.com/thisscribe000/CheckerChecks/blob/main/metadata/com.checkerchecks.checkerchecks.yml)

---

## 2. Automated `fdroid-bot` Scan Report

Automated GitLab CI Job **#16461106970** analyzed the submission and recorded the following:

| Item | Result | Details |
| :--- | :---: | :--- |
| **Fastlane Metadata** | **PASSED** | Correctly parsed `en-US` title, short summary, and full description from `fastlane/metadata/android/en-US/`. |
| **VirusTotal Scan** | **CLEAN** | Scanned release APK with 0 detections. [VirusTotal Report](https://www.virustotal.com/gui/file/a4e9925e17569d603f51bf6c9637f04d159fcd13b6ef0be7a720469ce03d3f91/detection). |
| **Gradle Wrapper Checksum** | **FIXED** | Bot flagged `missing distributionSha256Sum` (`insecure-gradlew`). Fixed in commit `f124faf`. |
| **Spurious Tags** | **FIXED** | Bot assigned `react` and `react-native` labels because root `node_modules` was tracked in git. Purged and ignored in commit `f124faf`. |

---

## 3. Remediation Applied to Repository

### A. Gradle Wrapper Verification
Added official Gradle 8.14 checksum to [`android/gradle/wrapper/gradle-wrapper.properties`](file:///Users/christembassyabujazone1/projects/CheckerChecks/android/gradle/wrapper/gradle-wrapper.properties):
```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip
distributionSha256Sum=efe9a3d147d948d7528a9887fa35abcf24ca1a43ad06439996490f77569b02d1
```

### B. Cleaned Git History of Web Artifacts
- Removed 3,350+ non-Flutter files from `node_modules/` and `dist/`.
- Updated [`.gitignore`](file:///Users/christembassyabujazone1/projects/CheckerChecks/.gitignore) to exclude `node_modules/` and `dist/`.
- Committed and pushed to GitHub main (`f124faf`).

---

## 4. How to Check Live Status Anytime

### Quick CLI Check via GitLab GraphQL
Run this command from your terminal to fetch the latest comments and status on RFP #4383:

```bash
python3 -c "
import urllib.request, json

query = '''query {
  project(fullPath: \"fdroid/rfp\") {
    issue(iid: \"4383\") {
      title
      state
      notes {
        nodes {
          author { username }
          body
          createdAt
        }
      }
    }
  }
}'''

req = urllib.request.Request('https://gitlab.com/api/graphql', 
  data=json.dumps({'query': query}).encode('utf-8'),
  headers={'Content-Type': 'application/json'})

data = json.loads(urllib.request.urlopen(req).read().decode('utf-8'))['data']['project']['issue']
print('STATE:', data['state'])
for n in data['notes']['nodes']:
    print(f'[{n[\"createdAt\"]}] {n[\"author\"][\"username\"]}: {n[\"body\"][:120]}...')
"
```

---

## 5. Alternative / Fast-Track: IzzyOnDroid

While waiting for F-Droid maintainers to package and publish RFP #4383:
- **IzzyOnDroid Repo**: Usually accepts and publishes APKs within 24–48 hours.
- **Submission Link**: [IzzyOnDroid Inclusion Request on Codeberg](https://codeberg.org/IzzyOnDroid/repodata/issues/new?template=inclusion_request.yaml)
- **Repository URL to provide**: `https://github.com/thisscribe000/CheckerChecks`
- **Release APK URL**: `https://github.com/thisscribe000/CheckerChecks/releases/download/v1.0.0/app-release.apk`
