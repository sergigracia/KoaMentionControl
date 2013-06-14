KoaMentionControl
=================

There are two options to use textview delegate:

1) KoaMentionControl manage textview delegate:
```objective-c
[self.textView setDelegate:self.KoaMentionControl];
```
2) You manage textview delegate:

```objective-c
[self.textView setDelegate:self];
```
and you must to call these 3 events:
```objective-c
- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self.KoaMentionControl textViewDidChangeSelection:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return [self.KoaMentionControl textView:textView shouldChangeTextInRange:range replacementText:text];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.KoaMentionControl textViewDidChange:textView];
}
```
