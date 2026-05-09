import { Platform } from "react-native";
import * as Print from "expo-print";
import * as Sharing from "expo-sharing";
import { Alert } from "react-native";

export async function printOrShareHtml(html: string, shareDialogTitle: string): Promise<void> {
  if (Platform.OS === "web") {
    const win = window.open("", "_blank");
    if (!win) {
      Alert.alert("Blocked", "Please allow pop-ups for this site to download PDFs.");
      return;
    }
    win.document.write(html);
    win.document.close();
    win.focus();
    setTimeout(() => {
      win.print();
    }, 500);
  } else {
    const { uri } = await Print.printToFileAsync({ html, base64: false });
    const canShare = await Sharing.isAvailableAsync();
    if (canShare) {
      await Sharing.shareAsync(uri, { mimeType: "application/pdf", dialogTitle: shareDialogTitle });
    } else {
      Alert.alert("Saved", `PDF saved to: ${uri}`);
    }
  }
}
