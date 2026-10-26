"use client";

import { useCallback, useMemo, useRef, useState, useSyncExternalStore } from "react";
import Link from "next/link";
import { ArrowRight, Check, Copy, ExternalLink, Play, Search } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";

export type CatalogueEntry = {
  id: string;
  kind: "layout" | "feature";
  name: string;
  category: string;
  evidence: string;
  use: string;
  code: string;
  classes: string[];
  caveat: string;
  preview: string;
  snippet: string;
};

function resolveEntryFromHash(entries: CatalogueEntry[]) {
  const prefix = "#layout/";
  if (!window.location.hash.startsWith(prefix)) return null;
  const id = decodeURIComponent(window.location.hash.slice(prefix.length));
  return entries.find((entry) => entry.id === id) ?? null;
}

export default function LearningHub({ initialEntries }: { initialEntries: CatalogueEntry[] }) {
  const [entries] = useState(initialEntries);
  const [query, setQuery] = useState("");
  const [category, setCategory] = useState("All");
  const subscribeToHash = useCallback((listener: () => void) => {
    window.addEventListener("hashchange", listener);
    return () => window.removeEventListener("hashchange", listener);
  }, []);
  const getSelectedFromHash = useCallback(() => resolveEntryFromHash(entries), [entries]);
  const selected = useSyncExternalStore(subscribeToHash, getSelectedFromHash, () => null);
  const [copied, setCopied] = useState(false);
  const dialogTitleRef = useRef<HTMLHeadingElement>(null);

  const layouts = useMemo(() => entries.filter((entry) => entry.kind === "layout"), [entries]);
  const features = useMemo(() => entries.filter((entry) => entry.kind === "feature"), [entries]);
  const categories = useMemo(
    () => ["All", ...Array.from(new Set(layouts.map((layout) => layout.category)))],
    [layouts],
  );

  const visibleLayouts = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    return layouts.filter((layout) => {
      const inCategory = category === "All" || layout.category === category;
      const searchable = [layout.name, layout.use, layout.evidence, layout.code, layout.category, ...layout.classes].join(" ").toLowerCase();
      return inCategory && (!normalizedQuery || searchable.includes(normalizedQuery));
    });
  }, [layouts, query, category]);

  function openEntry(entry: CatalogueEntry) {
    setCopied(false);
    window.history.replaceState(null, "", `#layout/${encodeURIComponent(entry.id)}`);
    window.dispatchEvent(new HashChangeEvent("hashchange"));
  }

  function closeEntry() {
    setCopied(false);
    window.history.replaceState(null, "", "#layouts");
    window.dispatchEvent(new HashChangeEvent("hashchange"));
  }

  async function copySnippet() {
    if (!selected) return;
    await navigator.clipboard.writeText(selected.snippet);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1800);
  }

  return (
    <main>
      <header className="site-header">
        <div className="brand">
          <a href="https://deepwaterimr.github.io/fiskwise/" aria-label="Fiskwise home">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img className="brand-wordmark" src="./fiskwise/wordmark.svg" alt="Fiskwise" />
          </a>
          <Link className="brand-product" href="#top" aria-label="wise-presentations home">wise-presentations</Link>
        </div>
        <nav aria-label="Primary navigation">
          <Link href="#layouts">Layouts</Link>
          <Link href="#start">Setup</Link>
          <a href="https://github.com/DeepWaterIMR/wise-presentations">GitHub</a>
          <a href="https://deepwaterimr.github.io/fiskwise/">Fiskwise</a>
        </nav>
      </header>

      <section className="hero" id="top">
        <div className="hero-copy">
          <p className="eyebrow">Quarto layouts for scientific presentations</p>
          <h1>Match each scientific claim with an appropriate slide layout.</h1>
          <p className="hero-lead">wise-presentations provides reusable layouts, reproducible figure workflows, and rendering checks for academic presentations.</p>
          <div className="hero-actions">
            <Link className="button button-primary" href="#layouts">Browse layouts <ArrowRight aria-hidden="true" /></Link>
            <Link className="button button-secondary" href="./demo/presentation.html"><Play aria-hidden="true" /> Open sampler</Link>
            <a className="text-link" href="https://github.com/DeepWaterIMR/wise-presentations"><ExternalLink aria-hidden="true" /> View repository</a>
          </div>
          <div className="hero-feature-points" aria-label="Template features">
            <span>Quarto and RevealJS</span>
            <span>17 reusable layouts</span>
            <span>Source-linked examples</span>
          </div>
        </div>
        <div className="hero-preview" aria-label="Example scientific slide preview">
          <div className="slide-preview">
            <div className="slide-title">The fitted trajectories support the main interpretation</div>
            <div className="slide-rule" />
            <div className="slide-body">
              <div className="slide-notes">
                <span />
                <span />
                <strong>State only the interpretation needed to read the figure.</strong>
              </div>
              <svg viewBox="0 0 360 180" aria-hidden="true">
                <path d="M24 132 C72 112 78 84 122 94 S185 44 232 67 S300 42 336 31" />
                <path className="coral" d="M24 45 C66 63 91 48 126 74 S190 93 225 78 S286 118 336 105" />
                <line x1="24" x2="336" y1="90" y2="90" />
              </svg>
            </div>
            <div className="slide-section">RESULTS</div>
          </div>
        </div>
      </section>

      <section className="section catalogue-section" id="layouts">
        <div className="catalogue-heading">
          <div className="section-heading">
            <p className="eyebrow">Slide layout catalogue</p>
            <h2>Each layout is shown with a rendered example and its Quarto source.</h2>
            <p>The displayed name and code refer to the same composition, so a layout can be requested unambiguously.</p>
          </div>
          <Link className="text-link" href="./demo/presentation.html">{entries.length ? `Open all ${entries.length} examples` : "Open all examples"} <Play aria-hidden="true" /></Link>
        </div>

        <div className="catalogue-controls">
          <div className="search-field">
            <Search aria-hidden="true" />
            <label className="sr-only" htmlFor="layout-search">Search slide layouts</label>
            <Input id="layout-search" value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Search layouts, evidence types, or classes" />
          </div>
          <div className="category-filters" aria-label="Filter layouts by category">
            {categories.map((name) => (
              <Button key={name} variant={category === name ? "default" : "outline"} size="sm" onClick={() => setCategory(name)} aria-pressed={category === name}>{name}</Button>
            ))}
          </div>
        </div>

        {layouts.length > 0 && visibleLayouts.length === 0 ? <p className="state-message">No layouts match this search. Try another evidence type or category.</p> : null}

        <div className="layout-grid">
          {visibleLayouts.map((layout) => (
            <button className="layout-card" key={layout.id} type="button" onClick={() => openEntry(layout)} aria-label={`Inspect ${layout.name}`}>
              <span className="layout-image">
                {/* oxlint-disable-next-line next/no-img-element */}
                <img src={`./${layout.preview}`} alt="" loading="lazy" />
              </span>
              <span className="layout-content">
                <span className="tag">{layout.category}</span>
                <span className="layout-title">{layout.name}</span>
                <code className="layout-code">{layout.code}</code>
                <span className="layout-use">{layout.use}</span>
                <span className="layout-open">Inspect layout <ArrowRight aria-hidden="true" /></span>
              </span>
            </button>
          ))}
        </div>
      </section>

      <section className="section features-section" id="features">
        <div className="section-heading">
          <p className="eyebrow">Features and modifiers</p>
          <h2>Rendering features are documented separately from slide layouts.</h2>
          <p>These examples cover fragments, emphasis, background images, custom figure fonts, and table density. They modify a layout rather than replace one.</p>
        </div>
        <div className="feature-grid">
          {features.map((feature) => (
            <button className="feature-card" key={feature.id} type="button" onClick={() => openEntry(feature)} aria-label={`Inspect ${feature.name}`}>
              <span className="tag">{feature.category}</span>
              <span className="feature-title">{feature.name}</span>
              <code>{feature.code}</code>
              <span>{feature.use}</span>
              <span className="layout-open">Inspect feature <ArrowRight aria-hidden="true" /></span>
            </button>
          ))}
        </div>
      </section>

      <section className="section workflow-section" id="start">
        <div className="section-heading">
          <p className="eyebrow">Setup</p>
          <h2>Start with wise-writing; add presentation workflows when you need them.</h2>
          <p>wise-writing is the Fiskwise core. wise-presentations is an optional add-on for planning, building, and reviewing Quarto slide decks.</p>
        </div>
        <p className="authoring-note">Use transparent plot, panel, and legend backgrounds; add <code>transparent_bg()</code> after a package theme. End the final slide with a <code>.credit-note</code> naming Quarto, wise-presentations, and the building agent’s model from <code>project.ai_model</code> in <code>presentation.yml</code>.</p>
        <p className="authoring-note">Agent skill setup does not install R, Quarto, R packages, or model software. Standalone install and update skills are available for this pack. The direct project starter copies files into an existing analysis project. Missing R packages are not installed by default; <code>renv</code> projects remain managed by renv. Install the Quarto CLI separately from the R package <code>quarto</code>.</p>
        <div className="quickstart-grid">
          <article className="quickstart-card featured">
            <p className="eyebrow">Fiskwise core</p>
            <h3>Install wise-writing as the core research pack.</h3>
            <p>Start with shared scientific writing, R, and Quarto guidance. Presentation workflows remain optional.</p>
            <pre><code>install https://github.com/DeepWaterIMR/fiskwise</code></pre>
          </article>
          <article className="quickstart-card">
            <p className="eyebrow">Optional add-on</p>
            <h3>Add wise-presentations when you are ready to make a deck.</h3>
            <p>Install the <code>make-presentation</code> and <code>review-presentation</code> skills alongside wise-writing.</p>
            <pre><code>install https://github.com/DeepWaterIMR/wise-presentations</code></pre>
          </article>
          <article className="quickstart-card">
            <p className="eyebrow">Direct project starter</p>
            <h3>Copy a presentation starter into an existing analysis project.</h3>
            <pre><code>{`Rscript install_into_project.R \\
  --target "/path/to/project"`}</code></pre>
            <p>The default destination is <code>docs/presentation/</code>. This copies files into one project; it does not install global skills. Existing project-level agent guidance is not overwritten.</p>
          </article>
        </div>
      </section>

      <section className="section contribution-panel">
        <div>
          <p className="eyebrow">Contribute</p>
          <h2>New layouts require a source example, catalogue record, rendered preview, and validation.</h2>
        </div>
        <div className="contribution-actions">
          <a className="button button-primary" href="https://github.com/DeepWaterIMR/wise-presentations/blob/main/CONTRIBUTING.md">Contribution guide <ArrowRight aria-hidden="true" /></a>
          <a className="button button-secondary" href="https://github.com/DeepWaterIMR/wise-presentations/issues">Report an issue <ExternalLink aria-hidden="true" /></a>
        </div>
      </section>

      <footer>
        <span>wise-presentations</span>
        <span>Quarto source · Self-contained HTML · MIT-licensed code · <a href="https://deepwaterimr.github.io/fiskwise/">Fiskwise home</a></span>
      </footer>

      <Dialog open={Boolean(selected)} onOpenChange={(open) => { if (!open) closeEntry(); }}>
        {selected ? (
          <DialogContent className="layout-dialog" initialFocus={dialogTitleRef}>
            <DialogHeader>
              <div className="dialog-heading-row">
                <span className="tag">{selected.kind === "layout" ? selected.category : "Feature"}</span>
                <code className="class-list">{selected.code}</code>
              </div>
              <DialogTitle ref={dialogTitleRef} tabIndex={-1}>{selected.name}</DialogTitle>
              <DialogDescription>{selected.use}</DialogDescription>
            </DialogHeader>
            <div className="dialog-grid">
              <div className="dialog-preview">
                {/* oxlint-disable-next-line next/no-img-element */}
                <img src={`./${selected.preview}`} alt={`Rendered example of ${selected.name}`} />
                <div className="dialog-facts">
                  <div><span>Evidence or explanation</span><strong>{selected.evidence}</strong></div>
                  <div><span>Consideration</span><strong>{selected.caveat}</strong></div>
                </div>
              </div>
              <div className="snippet-panel">
                <div className="snippet-header">
                  <span>Quarto source</span>
                  <Button size="sm" variant="outline" onClick={copySnippet}>{copied ? <Check aria-hidden="true" /> : <Copy aria-hidden="true" />}{copied ? "Copied" : "Copy"}</Button>
                </div>
                <pre><code>{selected.snippet}</code></pre>
                <span className="copy-status" aria-live="polite">{copied ? `${selected.kind === "layout" ? "Layout" : "Feature"} source copied to the clipboard.` : ""}</span>
              </div>
            </div>
          </DialogContent>
        ) : null}
      </Dialog>
    </main>
  );
}
