"use client";

import { useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import {
  Type,
  Heading1,
  Heading2,
  Heading3,
  List,
  ListOrdered,
  CheckSquare,
  FileText,
  Quote,
  Code,
  Image,
  Minus,
  Table,
  Database,
} from "lucide-react";

interface SlashMenuProps {
  position: { x: number; y: number };
  onSelect: (type: string) => void;
  onClose: () => void;
}

const menuItems = [
  {
    type: "TEXT",
    label: "Text",
    description: "Just start writing with plain text",
    icon: Type,
    keywords: ["text", "paragraph", "p"],
  },
  {
    type: "HEADING_1",
    label: "Heading 1",
    description: "Big section heading",
    icon: Heading1,
    keywords: ["heading", "h1", "title"],
  },
  {
    type: "HEADING_2",
    label: "Heading 2",
    description: "Medium section heading",
    icon: Heading2,
    keywords: ["heading", "h2", "subtitle"],
  },
  {
    type: "HEADING_3",
    label: "Heading 3",
    description: "Small section heading",
    icon: Heading3,
    keywords: ["heading", "h3"],
  },
  {
    type: "BULLET_LIST",
    label: "Bulleted list",
    description: "Create a simple bulleted list",
    icon: List,
    keywords: ["list", "bullet", "ul"],
  },
  {
    type: "NUMBERED_LIST",
    label: "Numbered list",
    description: "Create a list with numbering",
    icon: ListOrdered,
    keywords: ["list", "numbered", "ol"],
  },
  {
    type: "TODO",
    label: "To-do list",
    description: "Track tasks with a to-do list",
    icon: CheckSquare,
    keywords: ["todo", "task", "checkbox"],
  },
  {
    type: "QUOTE",
    label: "Quote",
    description: "Capture a quote",
    icon: Quote,
    keywords: ["quote", "blockquote"],
  },
  {
    type: "CODE",
    label: "Code",
    description: "Capture a code snippet",
    icon: Code,
    keywords: ["code", "snippet"],
  },
  {
    type: "DIVIDER",
    label: "Divider",
    description: "Visually divide blocks",
    icon: Minus,
    keywords: ["divider", "separator", "hr"],
  },
  {
    type: "IMAGE",
    label: "Image",
    description: "Upload or embed with a link",
    icon: Image,
    keywords: ["image", "picture", "photo"],
  },
  {
    type: "TABLE",
    label: "Table",
    description: "Create a table",
    icon: Table,
    keywords: ["table", "grid"],
  },
  {
    type: "DATABASE",
    label: "Database",
    description: "Create a database",
    icon: Database,
    keywords: ["database", "db", "data"],
  },
  {
    type: "PAGE",
    label: "Sub-page",
    description: "Create a page inside this page",
    icon: FileText,
    keywords: ["page", "subpage", "nested"],
  },
];

export function SlashMenu({ position, onSelect, onClose }: SlashMenuProps) {
  const [selectedIndex, setSelectedIndex] = useState(0);
  const [searchQuery, setSearchQuery] = useState("");

  const filteredItems = menuItems.filter(
    (item) =>
      item.label.toLowerCase().includes(searchQuery.toLowerCase()) ||
      item.keywords.some((keyword) =>
        keyword.includes(searchQuery.toLowerCase())
      )
  );

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      switch (e.key) {
        case "ArrowDown":
          e.preventDefault();
          setSelectedIndex((prev) =>
            prev < filteredItems.length - 1 ? prev + 1 : 0
          );
          break;
        case "ArrowUp":
          e.preventDefault();
          setSelectedIndex((prev) =>
            prev > 0 ? prev - 1 : filteredItems.length - 1
          );
          break;
        case "Enter":
          e.preventDefault();
          if (filteredItems[selectedIndex]) {
            onSelect(filteredItems[selectedIndex].type);
          }
          break;
        case "Escape":
          e.preventDefault();
          onClose();
          break;
      }
    };

    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [selectedIndex, filteredItems, onSelect, onClose]);

  useEffect(() => {
    setSelectedIndex(0);
  }, [searchQuery]);

  return (
    <div
      className="slash-menu"
      style={{
        left: position.x,
        top: position.y,
      }}
    >
      <div className="p-2 border-b">
        <input
          type="text"
          placeholder="Search for a block type..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="w-full text-sm border-none outline-none bg-transparent"
          autoFocus
        />
      </div>

      <div className="max-h-64 overflow-y-auto">
        {filteredItems.length === 0 ? (
          <div className="p-4 text-center text-gray-500 text-sm">
            No blocks found
          </div>
        ) : (
          filteredItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                key={item.type}
                className={`slash-menu-item w-full text-left ${
                  index === selectedIndex ? "selected" : ""
                }`}
                onClick={() => onSelect(item.type)}
              >
                <Icon className="slash-menu-item-icon" />
                <div className="flex-1">
                  <div className="font-medium text-sm">{item.label}</div>
                  <div className="text-xs text-gray-500">
                    {item.description}
                  </div>
                </div>
              </button>
            );
          })
        )}
      </div>
    </div>
  );
}
