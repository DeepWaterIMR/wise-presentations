import LearningHub from "./learning-hub";
import catalogue from "../public/layouts.json";
import type { CatalogueEntry } from "./learning-hub";

export const dynamic = "force-static";

export default function Page() {
  return <LearningHub initialEntries={catalogue.entries as CatalogueEntry[]} />;
}
